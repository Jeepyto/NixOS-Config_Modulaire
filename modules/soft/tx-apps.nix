{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.utilities.txApps;
in
{
  options.tx.utilities.txApps.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Installe la commande tx-apps (TUI gum pour activer/desactiver les applications, puis lance tx-update).";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.callPackage ../../pkgs/tx-apps.nix {})
      pkgs.gum
      pkgs.gnome-console
    ];
  };
}
