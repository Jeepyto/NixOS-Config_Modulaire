{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.trcc;
in
{
  options.tx.system.trcc.enable = mkOption {
    type = types.bool;
    default = true;
    description = "TRCC ThermalRight - Affichage de mon ventirad.";
  };

  config = mkIf cfg.enable {
    programs.trcc-linux.enable = true;
  };
}
