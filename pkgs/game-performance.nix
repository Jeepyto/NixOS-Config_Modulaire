{ pkgs }:
# Usage Steam (options de lancement) : game-performance %COMMAND%
# Usage Lutris (wrapper)              : game-performance
pkgs.writeShellScriptBin "game-performance" ''
  set -u

  if [ $# -eq 0 ]; then
    echo "Usage: game-performance <commande_du_jeu> [arguments...]"
    exit 1
  fi

  cleanup() {
    set +e
    echo "==> Retour au profil 'balanced'."
    powerprofilesctl set balanced

    echo "==> Redemarrage d'ananicy-cpp."
    systemctl start ananicy-cpp.service
  }
  trap cleanup EXIT INT TERM

  echo "==> Arret d'ananicy-cpp (conflit avec GameMode)."
  systemctl stop ananicy-cpp.service

  echo "==> Passage en profil 'performance'."
  powerprofilesctl set performance

  echo "==> Lancement (via gamemoderun) : $*"
  ${pkgs.gamemode}/bin/gamemoderun "$@" &
  child_pid=$!

  set +e
  wait "$child_pid"
  exit $?
''