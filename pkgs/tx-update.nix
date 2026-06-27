{ pkgs }:

pkgs.writeShellScriptBin "tx-update" ''
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  GRAY='\033[0;90m'
  BOLD='\033[1m'
  NC='\033[0m'

  STEP_NAMES=("Verification reseau" "Mise a jour flake.lock" "Rebuild NixOS (nh)" "Resultat")
  STEP_STATUS=(pending pending pending pending)
  STEP_DETAIL=("" "" "" "")
  TOTAL_STEPS=''${#STEP_NAMES[@]}
  GRAPH_LINES=0

  tput civis 2>/dev/null || true
  trap 'tput cnorm 2>/dev/null || true' EXIT

  icon_for() {
    case "$1" in
      done) echo -e "''${GREEN}✓''${NC}" ;;
      running) echo -e "''${YELLOW}◉''${NC}" ;;
      failed) echo -e "''${RED}✗''${NC}" ;;
      *) echo -e "''${GRAY}○''${NC}" ;;
    esac
  }

  draw_graph() {
    if [ "$GRAPH_LINES" -gt 0 ]; then
      tput cuu "$GRAPH_LINES" 2>/dev/null || true
    fi

    local out=""
    out+="''${BOLD}tx-update''${NC}\n"
    local i
    for i in "''${!STEP_NAMES[@]}"; do
      local icon
      icon=$(icon_for "''${STEP_STATUS[$i]}")
      local name="''${STEP_NAMES[$i]}"
      local detail="''${STEP_DETAIL[$i]}"
      local connector=" "
      if [ "$i" -lt "$((TOTAL_STEPS - 1))" ]; then
        connector="│"
      fi

      case "''${STEP_STATUS[$i]}" in
        running) out+="  ''${icon}  ''${BOLD}''${name}''${NC}" ;;
        done)    out+="  ''${icon}  ''${GREEN}''${name}''${NC}" ;;
        failed)  out+="  ''${icon}  ''${RED}''${name}''${NC}" ;;
        *)       out+="  ''${icon}  ''${GRAY}''${name}''${NC}" ;;
      esac
      if [ -n "$detail" ]; then
        out+="  ''${GRAY}(''${detail})''${NC}"
      fi
      out+="\n"
      out+="  ''${GRAY}''${connector}''${NC}\n"
    done

    out=$(echo -e "$out" | sed 's/$/\x1b[K/')
    printf '%s\n' "$out"
    GRAPH_LINES=$(printf '%s\n' "$out" | wc -l)
  }

  set_status() {
    local idx=$1 status=$2 detail=$3
    STEP_STATUS[$idx]=$status
    STEP_DETAIL[$idx]=$detail
    draw_graph
  }

  echo ""
  draw_graph
  
  set_status 0 running ""
  OLD_SYSTEM=$(readlink -f /run/current-system)
  COUNTER=0
  NETWORK_OK=0
  while true; do
    if ${pkgs.iputils}/bin/ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 && \
       ${pkgs.iputils}/bin/ping -c1 -W2 cache.nixos.org >/dev/null 2>&1; then
      NETWORK_OK=1
      break
    fi
    COUNTER=$((COUNTER+1))
    if [ $COUNTER -ge 12 ]; then
      break
    fi
    set_status 0 running "tentative ''${COUNTER}/12"
    sleep 5
  done

  if [ "$NETWORK_OK" -ne 1 ]; then
    set_status 0 failed "60s ecoulees"
    echo -e "''${RED}Pas de reseau apres 60s, abandon.''${NC}"
    exit 1
  fi
  set_status 0 done ""
  
  set_status 1 running ""
  echo -e "''${GRAY}--- sortie de 'nix flake update' ---''${NC}"
  if ! sudo ${pkgs.nix}/bin/nix flake update --flake /etc/nixos; then
    set_status 1 failed "echec"
    echo -e "''${RED}Echec de la mise a jour du flake.lock.''${NC}"
    exit 1
  fi
  set_status 1 done ""

  set_status 2 running "peut prendre plusieurs minutes"
  echo -e "''${GRAY}--- sortie de 'nh os switch' ---''${NC}"
  ${pkgs.nh}/bin/nh os switch /etc/nixos#nixos
  REBUILD_STATUS=$?

  NEW_SYSTEM=$(readlink -f /run/current-system)

  if [ $REBUILD_STATUS -ne 0 ]; then
    set_status 2 failed "code ''${REBUILD_STATUS}"
    set_status 3 failed ""
    echo -e "''${RED}Echec de la mise a jour (voir les logs ci-dessus).''${NC}"
    exit $REBUILD_STATUS
  fi
  set_status 2 done ""

  set_status 3 running ""
  if [ "$OLD_SYSTEM" = "$NEW_SYSTEM" ]; then
    set_status 3 done "deja a jour"
    echo -e "''${GREEN}Systeme deja a jour, rien a changer.''${NC}"
  else
    set_status 3 done "diff affiche ci-dessus par nh"
    echo -e "''${GREEN}Mise a jour reussie.''${NC}"
  fi
''
