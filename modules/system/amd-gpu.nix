{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.hardwareGpu;
in
{
  options.tx.system.hardwareGpu.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Pilotes graphiques accélérés (Mesa) pour GPU AMD, support 32-bit, VAAPI radeonsi.";
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable      = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
        libva-utils
      ];
    };

    environment.variables = {
      MESA_SHADER_CACHE_MAX_SIZE = "12G";
      LIBVA_DRIVER_NAME = "radeonsi";
    };
  };
}
