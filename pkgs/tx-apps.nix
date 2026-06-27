{ pkgs }:

let
  tx-apps-bin = pkgs.writeShellScriptBin "tx-apps" ''
    set -euo pipefail
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
    LIB_FILE="/etc/nixos/lib/default.nix"
    if [ ! -f "$LIB_FILE" ]; then
      echo -e "''${RED}Fichier introuvable : ''${LIB_FILE}''${NC}"
      exit 1
    fi
    OPTION_PATHS=(
      "tx.communication.discord.enable"
      "tx.communication.element.enable"
      "tx.dev.vscode.enable"
      "tx.dev.dbeaver.enable"
      "tx.dev.tigervnc.enable"
      "tx.dev.virtualMachine.enable"
      "tx.gaming.steam.enable"
      "tx.gaming.faugus.enable"
      "tx.office.libreOffice.enable"
      "tx.streaming.obsStudio.enable"
      "tx.studio.freecad.enable"
      "tx.studio.blender.enable"
      "tx.utilitaires.gparted.enable"
    )
    OPTION_LABELS=(
      "Discord"
      "Element"
      "VS Code"
      "DBeaver"
      "TigerVNC"
      "Machine virtuelle (virt-manager)"
      "Steam"
      "Faugus"
      "LibreOffice"
      "OBS Studio"
      "FreeCAD"
      "Blender"
      "GParted"
    )
    if ! command -v ${pkgs.gum}/bin/gum >/dev/null 2>&1; then
      echo -e "''${RED}gum est introuvable.''${NC}"
      exit 1
    fi
    CURRENT_VALUES=()
    for path in "''${OPTION_PATHS[@]}"; do
      value=$(${pkgs.gnugrep}/bin/grep -oP "^\s*''${path//./\\.}\s*=\s*(true|false)" "$LIB_FILE" \
        | ${pkgs.gnugrep}/bin/grep -oP '(true|false)$' || echo "false")
      CURRENT_VALUES+=("$value")
    done
    MENU_ITEMS=()
    SELECTED_ITEMS=()
    for i in "''${!OPTION_PATHS[@]}"; do
      label="''${OPTION_LABELS[$i]}"
      MENU_ITEMS+=("$label")
      if [ "''${CURRENT_VALUES[$i]}" = "true" ]; then
        SELECTED_ITEMS+=("$label")
      fi
    done
    if [ "''${#SELECTED_ITEMS[@]}" -gt 0 ]; then
      SELECTED_JOINED=$(printf "%s," "''${SELECTED_ITEMS[@]}")
      SELECTED_JOINED="''${SELECTED_JOINED%,}"
    else
      SELECTED_JOINED=""
    fi
    echo -e "''${YELLOW}Espace pour cocher/decocher, Entree pour valider.''${NC}"
    echo ""
    set +e
    CHOSEN=$(printf '%s\n' "''${MENU_ITEMS[@]}" | ${pkgs.gum}/bin/gum choose --no-limit \
      --header "Applications a activer" \
      --selected "$SELECTED_JOINED")
    CHOOSE_STATUS=$?
    set -e
    if [ $CHOOSE_STATUS -ne 0 ]; then
      echo -e "''${YELLOW}Annule, aucun changement effectue.''${NC}"
      exit 0
    fi
    ${pkgs.gum}/bin/gum confirm "Appliquer ces changements et lancer tx-update ?" || {
      echo -e "''${YELLOW}Annule, aucun changement effectue.''${NC}"
      exit 0
    }
    TMP_FILE=$(mktemp)
    cp "$LIB_FILE" "$TMP_FILE"
    for i in "''${!OPTION_PATHS[@]}"; do
      path="''${OPTION_PATHS[$i]}"
      label="''${OPTION_LABELS[$i]}"
      new_value="false"
      while IFS= read -r line; do
        if [ "$line" = "$label" ]; then
          new_value="true"
          break
        fi
      done <<< "$CHOSEN"
      if ! ${pkgs.gnugrep}/bin/grep -qP "^\s*''${path//./\\.}\s*=\s*(true|false)\s*;" "$TMP_FILE"; then
        echo -e "''${RED}Option introuvable dans ''${LIB_FILE} : ''${path}''${NC}"
        echo -e "''${RED}Le fichier n'a pas ete modifie pour cette option.''${NC}"
        continue
      fi
      ${pkgs.gnused}/bin/sed -i \
        "s|^\(\s*''${path//./\\.}\s*=\s*\)[a-z]*\(;\)|\1''${new_value}\2|" \
        "$TMP_FILE"
    done
    mv "$TMP_FILE" "$LIB_FILE"
    echo -e "''${GREEN}Configuration mise a jour.''${NC}"
    echo ""
    exec tx-update
  '';

  desktopEntry = pkgs.makeDesktopItem {
    name = "tx-apps";
    desktopName = "tx-apps";
    comment = "Activer ou desactiver les applications installees";
    exec = "${pkgs.gnome-console}/bin/kgx -- ${tx-apps-bin}/bin/tx-apps";
    icon = "tx-apps";
    terminal = false;
    categories = [ "Settings" "System" ];
  };

  # Icones multi-tailles attendues par le theme hicolor de GNOME.
  # Les fichiers source (tx-apps-16.png ... tx-apps-512.png) doivent se
  # trouver a cote de ce fichier .nix, dans ./assets/.
  iconSizes = [ 16 24 32 48 64 96 128 256 512 ];
  assetsDir = ./assets;
in
pkgs.symlinkJoin {
  name = "tx-apps";
  paths = [ tx-apps-bin desktopEntry ];
  postBuild = ''
    ${pkgs.lib.concatMapStringsSep "\n" (size: ''
      mkdir -p $out/share/icons/hicolor/${toString size}x${toString size}/apps
      cp ${assetsDir}/tx-apps-${toString size}.png $out/share/icons/hicolor/${toString size}x${toString size}/apps/tx-apps.png
    '') iconSizes}
  '';
}
