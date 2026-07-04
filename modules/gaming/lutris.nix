{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.gaming.lutris;
in
{
  options.tx.gaming.lutris.enable = mkEnableOption "Lutris";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.lutris.override {
        extraPkgs = pkgs: with pkgs; [
          vulkan-loader
          libva
        ];
      })
    ];
  };
}