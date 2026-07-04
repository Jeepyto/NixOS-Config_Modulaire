{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.gaming.heroic;
in
{
  options.tx.gaming.heroic.enable = mkEnableOption "Heroic Games Launcher";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.heroic
    ];
  };
}