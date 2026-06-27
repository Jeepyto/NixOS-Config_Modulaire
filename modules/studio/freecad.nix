{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.studio.freecad;
in
{
  options.tx.studio.freecad.enable = mkEnableOption "Freecad";

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.freecad ];
  };
}
