#!/usr/bin/env bash
# =============================================================================
#  LaMeDuSe - TP1 Virtualisation : verification du "clone source propre"
#
#  Usage   : sudo bash check_vm.sh            (doit etre lance en root)
#  Options : --no-color   desactive les couleurs
#            --offline    saute les tests qui necessitent Internet
#
#  Le script ne modifie RIEN sur la machine : il ne fait que lire et tester.
#  Code de retour : 0 si aucun KO, 1 sinon.
# =============================================================================

VERSION="1.0"

# ---------------------------------------------------------------- options ---
USE_COLOR=1
OFFLINE=0
for arg in "$@"; do
    case "$arg" in
        --no-color) USE_COLOR=0 ;;
        --offline)  OFFLINE=1 ;;
        -h|--help)
            sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "Option inconnue : $arg"; exit 2 ;;
    esac
done
[[ -t 1 ]] || USE_COLOR=0

if [[ $USE_COLOR -eq 1 ]]; then
    G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1;36m'; D=$'\e[2m'; N=$'\e[0m'
else
    G=""; R=""; Y=""; B=""; D=""; N=""
fi

PASS=0; FAIL=0; WARN=0

ok()      { printf "  %s[ OK ]%s %s\n" "$G" "$N" "$1"; PASS=$((PASS+1)); }
ko()      { printf "  %s[ KO ]%s %s\n" "$R" "$N" "$1"; FAIL=$((FAIL+1))
            [[ -n "${2:-}" ]] && printf "         %s-> %s%s\n" "$D" "$2" "$N"; }
warn()    { printf "  %s[WARN]%s %s\n" "$Y" "$N" "$1"; WARN=$((WARN+1))
            [[ -n "${2:-}" ]] && printf "         %s-> %s%s\n" "$D" "$2" "$N"; }
info()    { printf "  %s[INFO]%s %s\n" "$D" "$N" "$1"; }
section() { printf "\n%s== %s ==%s\n" "$B" "$1" "$N"; }

have() { command -v "$1" >/dev/null 2>&1; }

# ------------------------------------------------------------- pre-requis ---
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit etre lance en root (sudo bash $0)."
    exit 1
fi

printf "%s" "$B"
cat <<'EOF'
  _          __  __      ____        ____
 | |    __ _|  \/  | ___|  _ \ _   _/ ___|  ___
 | |   / _` | |\/| |/ _ \ | | | | | \___ \ / _ \
 | |__| (_| | |  | |  __/ |_| | |_| |___) |  __/
 |_____\__,_|_|  |_|\___|____/ \__,_|____/ \___|
EOF
printf "%s" "$N"
echo "  TP1 Virtualisation - verification du clone source (v$VERSION)"
echo "  $(date '+%Y-%m-%d %H:%M:%S')  -  $(hostname 2>/dev/null)"

# ================================================================ SYSTEME ===
section "1. Systeme & ressources"

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${ID:-}" == "rocky" && "${VERSION_ID:-}" == 10* ]]; then
        ok "Distribution : ${PRETTY_NAME}"
    else
        ko "Distribution attendue : Rocky Linux 10.x (trouve : ${PRETTY_NAME:-inconnue})"
    fi
else
    ko "/etc/os-release introuvable"
fi

mem_kb=$(awk '/^MemTotal/ {print $2}' /proc/meminfo)
mem_mb=$((mem_kb / 1024))
if (( mem_mb >= 1500 && mem_mb <= 2600 )); then
    ok "RAM : ${mem_mb} Mo (~2 Go attendus)"
else
    warn "RAM : ${mem_mb} Mo (2 Go attendus)"
fi

cpus=$(nproc 2>/dev/null || echo 0)
if [[ "$cpus" -eq 1 ]]; then
    ok "vCPU : $cpus"
else
    warn "vCPU : $cpus (1 attendu)"
fi

disk_line=$(lsblk -dnbo NAME,SIZE,TYPE 2>/dev/null | awk '$3=="disk" && $1 !~ /^(zram|loop|sr|nbd)/' | head -1)
disk_name=$(awk '{print $1}' <<<"$disk_line")
disk_gb=$(awk '{printf "%.1f", $2/1024/1024/1024}' <<<"$disk_line")
if awk -v s="$disk_gb" 'BEGIN{exit !(s>=9 && s<=11)}'; then
    ok "Disque /dev/${disk_name} : ${disk_gb} Go (~10 Go attendus)"
else
    warn "Disque /dev/${disk_name:-?} : ${disk_gb:-?} Go (10 Go attendus)"
fi

# =============================================================== HOSTNAME ===
section "2. Nom d'hote"

hn=$(hostnamectl hostname --static 2>/dev/null || hostnamectl --static 2>/dev/null || hostname)
if [[ -z "$hn" || "$hn" == localhost* || "$hn" == "rocky" ]]; then
    ko "Hostname par defaut ou vide : '${hn}'" "Donnez un nom explicite et persistant a la machine"
else
    ok "Hostname statique : $hn"
    if [[ "$hn" == *.* ]]; then
        ok "Hostname sous forme FQDN (nom.domaine)"
    else
        warn "Hostname sans domaine (FQDN conseille, ex : nom.domaine)"
    fi
    if getent hosts "$hn" >/dev/null 2>&1; then
        ok "Le hostname se resout localement"
    else
        warn "Le hostname ne se resout pas localement" "Que contient /etc/hosts ?"
    fi
fi

# ========================================================= PARTITIONNEMENT ===
section "3. Partitionnement & LVM"

check_lv_mount() {
    local mp="$1" src type
    src=$(findmnt -n -o SOURCE --mountpoint "$mp" 2>/dev/null | head -1)
    if [[ -z "$src" ]]; then
        ko "$mp n'est pas un point de montage separe"
        return
    fi
    type=$(lsblk -no TYPE "$src" 2>/dev/null | head -1)
    if [[ "$type" == "lvm" ]]; then
        local size use
        size=$(df -h --output=size "$mp" | tail -1 | tr -d ' ')
        use=$(df --output=pcent "$mp" | tail -1 | tr -d ' %')
        ok "$(printf '%-9s' "$mp") sur volume logique $src (${size}, ${use}% utilise)"
        if (( use >= 90 )); then
            warn "$mp est plein a ${use}%" "Le dimensionnement est-il adapte ?"
        fi
    else
        ko "$mp est monte depuis $src (type '$type'), pas depuis un volume logique"
    fi
}

for mp in / /home /var /var/log /tmp; do
    check_lv_mount "$mp"
done

boot_src=$(findmnt -n -o SOURCE --mountpoint /boot 2>/dev/null | head -1)
if [[ -z "$boot_src" ]]; then
    ko "/boot n'est pas une partition separee"
else
    boot_type=$(lsblk -no TYPE "$boot_src" 2>/dev/null | head -1)
    if [[ "$boot_type" == "part" ]]; then
        ok "/boot sur partition standard ($boot_src)"
    else
        warn "/boot sur '$boot_type' ($boot_src) - une partition standard est attendue"
    fi
fi

if [[ -d /sys/firmware/efi ]]; then
    if findmnt -n --mountpoint /boot/efi >/dev/null 2>&1; then
        ok "Machine UEFI : /boot/efi present"
    else
        ko "Machine UEFI mais /boot/efi absent"
    fi
else
    info "Machine demarree en mode BIOS (legacy)"
fi

swaps=$(swapon --show=NAME --noheadings 2>/dev/null)
if [[ -z "$swaps" ]]; then
    ko "Aucun swap actif"
else
    while read -r sw; do
        [[ -z "$sw" ]] && continue
        if [[ "$(lsblk -no TYPE "$sw" 2>/dev/null | head -1)" == "lvm" ]]; then
            ok "Swap actif sur volume logique $sw"
        else
            warn "Swap actif sur $sw (hors LVM)"
        fi
    done <<<"$swaps"
fi

if have vgs; then
    while read -r vg free; do
        [[ -z "$vg" ]] && continue
        info "Groupe de volumes '$vg' : ${free} libre(s)"
    done < <(vgs --noheadings --units g -o vg_name,vg_free 2>/dev/null)
fi

tmp_opts=$(findmnt -n -o OPTIONS --mountpoint /tmp 2>/dev/null)
if [[ -n "$tmp_opts" ]]; then
    missing=""
    for o in nodev nosuid noexec; do
        [[ ",$tmp_opts," == *",$o,"* ]] || missing+="$o "
    done
    if [[ -z "$missing" ]]; then
        ok "/tmp monte avec nodev,nosuid,noexec (bonus)"
    else
        warn "Bonus : options de montage absentes sur /tmp : ${missing}"
    fi
fi

# ================================================================ COMPTES ===
section "4. Comptes utilisateurs"

admins=()
humans=()
while IFS=: read -r user _ uid _ _ _ shell; do
    if (( uid >= 1000 && uid < 60000 )) && [[ "$shell" != */nologin && "$shell" != */false ]]; then
        humans+=("$user")
        if id -nG "$user" 2>/dev/null | tr ' ' '\n' | grep -qx wheel; then
            admins+=("$user")
        fi
    fi
done < <(getent passwd)

if (( ${#humans[@]} == 0 )); then
    ko "Aucun compte utilisateur (non-root) avec un shell de connexion"
else
    ok "Compte(s) utilisateur : ${humans[*]}"
fi

if (( ${#admins[@]} == 0 )); then
    ko "Aucun utilisateur n'a de droits d'administration (sudo)"
else
    ok "Administrateur(s) sudo non-root : ${admins[*]}"
fi

# ==================================================================== SSH ===
section "5. SSH & politique de securite"

if systemctl is-active --quiet sshd; then ok "sshd actif"; else ko "sshd n'est pas actif"; fi
if systemctl is-enabled --quiet sshd 2>/dev/null; then ok "sshd active au demarrage"; else ko "sshd n'est pas active au demarrage"; fi

if have sshd; then
    sshd_conf=$(sshd -T 2>/dev/null)
    if [[ -z "$sshd_conf" ]]; then
        ko "Impossible de lire la configuration effective de sshd (erreur de syntaxe ?)"
    else
        prl=$(awk '$1=="permitrootlogin" {print $2}' <<<"$sshd_conf")
        if [[ "$prl" == "no" ]]; then
            ok "Connexion SSH de root interdite"
        else
            ko "Connexion SSH de root encore possible (valeur effective : '$prl')" \
               "Pensez a TOUS les fichiers lus par sshd, pas seulement le principal"
        fi

        pwa=$(awk '$1=="passwordauthentication" {print $2}' <<<"$sshd_conf")
        if [[ "$pwa" == "no" ]]; then
            ok "Authentification par mot de passe desactivee (bonus)"
        else
            warn "Bonus : l'authentification SSH par mot de passe est encore active"
        fi

        port=$(awk '$1=="port" {print $2}' <<<"$sshd_conf" | head -1)
        info "Port SSH : ${port:-22}"

        banner=$(awk '$1=="banner" {print $2}' <<<"$sshd_conf")
        if [[ -n "$banner" && "$banner" != "none" && -s "$banner" ]]; then
            ok "Banniere SSH (avant authentification) : $banner"
        else
            ko "Aucune banniere legale affichee avant l'authentification SSH"
        fi
    fi
else
    ko "Binaire sshd introuvable"
fi

motd_found=0
[[ -s /etc/motd ]] && motd_found=1
if compgen -G "/etc/motd.d/*" >/dev/null; then
    for f in /etc/motd.d/*; do [[ -s "$f" ]] && motd_found=1; done
fi
if (( motd_found )); then
    ok "Message apres connexion (motd) present"
else
    warn "Aucun message affiche apres connexion (motd vide)"
fi

key_found=0
for u in "${humans[@]}"; do
    home=$(getent passwd "$u" | cut -d: -f6)
    [[ -s "$home/.ssh/authorized_keys" ]] && key_found=1
done
if (( key_found )); then
    ok "Au moins un utilisateur possede une cle SSH autorisee"
else
    warn "Aucune cle SSH deposee pour les utilisateurs"
fi

if have getenforce; then
    se=$(getenforce)
    if [[ "$se" == "Enforcing" ]]; then ok "SELinux : Enforcing"; else ko "SELinux : $se (Enforcing attendu)"; fi
fi

if systemctl is-active --quiet firewalld; then
    ok "firewalld actif"
    fw=$(firewall-cmd --list-all 2>/dev/null)
    sshport=${port:-22}
    if grep -qE "services:.*\bssh\b" <<<"$fw" || grep -qE "ports:.*\b${sshport}/tcp\b" <<<"$fw"; then
        ok "Le pare-feu autorise SSH"
    else
        warn "SSH n'apparait pas dans la zone par defaut du pare-feu"
    fi
else
    ko "firewalld n'est pas actif"
fi

if have update-crypto-policies; then
    info "Politique cryptographique systeme : $(update-crypto-policies --show 2>/dev/null)"
fi

# ================================================================== TEMPS ===
section "6. Synchronisation du temps (NTP)"

if systemctl is-active --quiet chronyd; then ok "chronyd actif"; else ko "chronyd n'est pas actif"; fi
if systemctl is-enabled --quiet chronyd 2>/dev/null; then ok "chronyd active au demarrage"; else ko "chronyd n'est pas active au demarrage"; fi

ntp_sync=$(timedatectl show -p NTPSynchronized --value 2>/dev/null)
if [[ "$ntp_sync" == "yes" ]]; then
    ok "Horloge synchronisee via NTP"
else
    ko "Horloge NON synchronisee via NTP"
fi

if have chronyc && chronyc -n sources 2>/dev/null | grep -q '^\^\*'; then
    ok "Une source NTP est selectionnee"
else
    warn "Aucune source NTP selectionnee pour le moment"
fi

tz=$(timedatectl show -p Timezone --value 2>/dev/null)
if [[ "$tz" == "Europe/Paris" ]]; then
    ok "Fuseau horaire : $tz"
else
    warn "Fuseau horaire : ${tz:-?} (Europe/Paris attendu)"
fi

# ================================================================= RESEAU ===
section "7. Reseau & acces Internet"

if ip route show default 2>/dev/null | grep -q default; then
    ok "Route par defaut : $(ip route show default | head -1 | awk '{print $3" via "$5}')"
else
    ko "Pas de route par defaut"
fi

while read -r ifname addr; do
    [[ "$ifname" == "lo" ]] && continue
    info "Interface $ifname : $addr"
done < <(ip -4 -o addr show 2>/dev/null | awk '{print $2, $4}')

if (( OFFLINE )); then
    info "Mode --offline : tests Internet ignores"
else
    if getent hosts rockylinux.org >/dev/null 2>&1; then ok "Resolution DNS fonctionnelle"; else ko "Resolution DNS en echec"; fi
    if curl -s -o /dev/null --max-time 10 https://rockylinux.org; then
        ok "Acces HTTPS vers Internet"
    else
        ko "Pas d'acces HTTPS vers Internet"
    fi
fi

# =============================================================== PAQUETS ===
section "8. Depots, mises a jour & paquets"

repos=$(dnf -q repolist --enabled 2>/dev/null | awk '$1!="repo" {print $1}')
for r in baseos appstream; do
    if grep -qx "$r" <<<"$repos"; then ok "Depot '$r' active"; else ko "Depot '$r' non active"; fi
done
info "Depots actives : $(tr '\n' ' ' <<<"$repos")"

if (( OFFLINE )); then
    info "Mode --offline : verification des mises a jour ignoree"
else
    echo "  ${D}... interrogation des depots (peut prendre une minute)${N}"
    upd_out=$(timeout 300 dnf -q check-update --refresh 2>/dev/null)
    rc=$?
    case $rc in
        0)   ok "Systeme a jour (aucune mise a jour disponible)" ;;
        100) n=$(grep -cE '^[[:alnum:]].*\.(x86_64|noarch|aarch64)[[:space:]]' <<<"$upd_out")
             ko "$n paquet(s) peuvent etre mis a jour" ;;
        124) ko "Verification des mises a jour : delai depasse" ;;
        *)   ko "Verification des mises a jour impossible (code $rc)" ;;
    esac
fi

if dnf needs-restarting --help >/dev/null 2>&1; then
    if dnf -q needs-restarting -r >/dev/null 2>&1; then
        ok "Aucun redemarrage necessaire"
    else
        warn "Un redemarrage est necessaire pour appliquer certaines mises a jour"
    fi
fi

latest_kernel=$(rpm -q --last kernel-core 2>/dev/null | head -1 | awk '{print $1}' | sed 's/^kernel-core-//')
if [[ -n "$latest_kernel" ]]; then
    if [[ "$(uname -r)" == "$latest_kernel" ]]; then
        ok "Le noyau en cours est le plus recent installe ($(uname -r))"
    else
        warn "Noyau en cours $(uname -r) != plus recent installe $latest_kernel"
    fi
fi

if rpm -q podman >/dev/null 2>&1; then
    ok "podman installe ($(podman --version 2>/dev/null))"
else
    ko "podman n'est pas installe"
fi

sub_ok=1
for u in "${admins[@]}"; do
    grep -q "^${u}:" /etc/subuid 2>/dev/null || sub_ok=0
done
if (( ${#admins[@]} > 0 )); then
    if (( sub_ok )); then
        ok "Plages subuid presentes (podman rootless possible)"
    else
        warn "Plages subuid manquantes pour un administrateur (podman rootless ?)"
    fi
fi

# ================================================================ RESUME ===
total=$((PASS + FAIL))
section "Resultat"
printf "  %sOK : %d%s   %sKO : %d%s   %sWARN : %d%s\n" "$G" "$PASS" "$N" "$R" "$FAIL" "$N" "$Y" "$WARN" "$N"
if (( total > 0 )); then
    printf "  Score : %d / %d (%d%%)\n" "$PASS" "$total" $(( PASS * 100 / total ))
fi
echo
if (( FAIL == 0 )); then
    echo "  ${G}Bravo : votre clone source est pret. Vous pouvez eteindre la VM proprement.${N}"
    exit 0
else
    echo "  ${R}Corrigez les points KO puis relancez le script.${N}"
    exit 1
fi
