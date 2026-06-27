{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.gaming.faugus;
in
{
  options.tx.gaming.faugus.enable = mkEnableOption "Faugus";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      faugus-launcher
    ];
  };
}