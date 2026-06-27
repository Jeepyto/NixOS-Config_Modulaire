{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.utilitaires.gparted;
in
{
  options.tx.utilitaires.gparted.enable = mkEnableOption "Gparted"; 

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gparted ];
  };
}
