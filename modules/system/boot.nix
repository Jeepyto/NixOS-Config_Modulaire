{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.boot;
in
{
  options.tx.system.boot.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Bootloader systemd-boot + variables EFI accessibles.";
  };

  config = mkIf cfg.enable {
    boot.loader.systemd-boot.enable      = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
