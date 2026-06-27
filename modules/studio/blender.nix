{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.studio.blender;
in
{
  options.tx.studio.blender.enable = mkEnableOption "Blender (build ROCm)";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgsRocm.blender
    ];

    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
    ];

    systemd.tmpfiles.rules = [
      "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
    ];
  };
}
