{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.gaming.gamePerformance;
in
{
  options.tx.gaming.gamePerformance = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "GameMode + power-profiles-daemon + script game-performance";
    };

    renice = mkOption {
      type = types.int;
      default = 10;
      description = "Niveau de renice appliqué par GameMode (general.renice).";
    };

    amdPerformanceLevel = mkOption {
      type = types.enum [ "auto" "low" "high" ];
      default = "high";
      description = "Niveau de performance GPU AMD appliqué par GameMode (gpu.amd_performance_level).";
    };
  };

  config = mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      settings = {
        general.renice = cfg.renice;
        gpu.amd_performance_level = cfg.amdPerformanceLevel;
      };
    };

    services.power-profiles-daemon.enable = true;

    environment.systemPackages = [
      (pkgs.callPackage ../../pkgs/game-performance.nix {})
    ];
  };
}
