{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.utilities.txUpdate;
in
{
  options.tx.utilities.txUpdate.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Installe la commande tx-update (flake update + rebuild via nh + graphe d'etapes).";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.callPackage ../../pkgs/tx-update.nix {})
      pkgs.nh
      pkgs.nix-output-monitor
    ];
  };
}
