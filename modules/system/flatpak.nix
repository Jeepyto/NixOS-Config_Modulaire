{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.flatpak;
in
{
  options.tx.system.flatpak.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Flatpak";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.flatpak
    ];
  };
}
