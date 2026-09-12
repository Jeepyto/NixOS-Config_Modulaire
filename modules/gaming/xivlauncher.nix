{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.gaming.ffxiv;

  gamePerformance = pkgs.callPackage ../../pkgs/game-performance.nix { };

  xivlauncher = pkgs.symlinkJoin {
    name = "xivlauncher";
    paths = [ pkgs.xivlauncher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      mv $out/bin/xivlauncher $out/bin/.xivlauncher-unwrapped

      makeWrapper ${if cfg.gamePerformance then "${gamePerformance}/bin/game-performance" else "$out/bin/.xivlauncher-unwrapped"} $out/bin/xivlauncher \
        ${optionalString cfg.gamePerformance ''--add-flags "$out/bin/.xivlauncher-unwrapped"''} \
        ${optionalString cfg.mangohud "--set MANGOHUD 1"} \
        --set WINEESYNC 1 \
        --set WINEFSYNC 1
    '';
  };
in
{
  options.tx.gaming.ffxiv = {
    enable = mkEnableOption "FFXIV (XIVLauncher)";

    gamePerformance = mkOption {
      type = types.bool;
      default = true;
      description = "Lance FFXIV via le script game-performance (coupe ananicy-cpp, profil performance, gamemoderun).";
    };

    mangohud = mkOption {
      type = types.bool;
      default = true;
      description = "MANGOHUD=1 — overlay de performance pour FFXIV.";
    };

    obsVKcapture = mkOption {
      type = types.bool;
      default = true;
      description = "OBS_VKCAPTURE=1 — permet de capturer FFXIV dans OBS Studio (nécessite le plugin obs-vkcapture).";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.xivlauncher ];
  };
}