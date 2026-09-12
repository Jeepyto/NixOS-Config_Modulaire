{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.hardware.openrazer;
in
{
  options.tx.hardware.openrazer = {
    enable = mkEnableOption "OpenRazer";

    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Utilisateurs ajoutés au groupe openrazer — nécessaire pour piloter les périphériques sans root.";
    };

    verboseLogging = mkOption {
      type = types.bool;
      default = false;
      description = "VERBOSE_LOGGING=1 — logs de debug du daemon OpenRazer.";
    };

    syncEffectsEnabled = mkOption {
      type = types.bool;
      default = true;
      description = "SYNC_EFFECTS=1 — synchronise les effets lumineux entre tous les périphériques Razer.";
    };

    devicesOffOnScreensaver = mkOption {
      type = types.bool;
      default = true;
      description = "DEVICES_OFF_ON_SCREENSAVER=1 — éteint les périphériques quand l'économiseur d'écran se déclenche.";
    };
  };

  config = mkIf cfg.enable {
    # DAEMON
    hardware.openrazer = {
      enable = true;
      users = cfg.users;
      verboseLogging = cfg.verboseLogging;
      syncEffectsEnabled = cfg.syncEffectsEnabled;
      devicesOffOnScreensaver = cfg.devicesOffOnScreensaver;
    };

    # PACKAGES
    environment.systemPackages = [ 
      pkgs.openrazer-daemon
      pkgs.polychromatic
   ];
  };
}