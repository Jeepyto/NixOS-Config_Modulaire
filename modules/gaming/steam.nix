{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.gaming.steam;
in
{
  options.tx.gaming.steam = {
    enable = mkEnableOption "Steam";

    mangohud = mkOption {
      type = types.bool;
      default = true;
      description = "MANGOHUD=1 — overlay de performance pour les jeux lancés via Steam.";
    };

    obsVkcapture = mkOption {
      type = types.bool;
      default = true;
      description = "OBS_VKCAPTURE=1 — capture Vulkan accélérée pour OBS.";
    };

    protonHighPriority = mkOption {
      type = types.bool;
      default = true;
      description = "PROTON_PRIORITY_HIGH=1 — priorise les process Proton sur le CPU.";
    };

    protonFsr4Upgrade = mkOption {
      type = types.bool;
      default = true;
      description = "PROTON_FSR4_UPGRADE=1 — force l'upscaling FSR4 sous Proton.";
    };
  };
  
  config = mkIf cfg.enable {
    programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = cfg.mangohud;
            OBS_VKCAPTURE = cfg.obsVkcapture;
            PROTON_PRIORITY_HIGH = cfg.protonHighPriority;
            PROTON_FSR4_UPGRADE = cfg.protonFsr4Upgrade;
          };
        };
      };
    hardware.steam-hardware.enable = true;
  };
}
