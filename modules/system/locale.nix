{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.locale;
in
{
  options.tx.system.locale.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Fuseau horaire Europe/Paris, locale fr_FR, clavier AZERTY.";
  };

  config = mkIf cfg.enable {
    time.timeZone      = "Europe/Paris";
    i18n.defaultLocale = "fr_FR.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS        = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT    = "fr_FR.UTF-8";
      LC_MONETARY       = "fr_FR.UTF-8";
      LC_NAME           = "fr_FR.UTF-8";
      LC_NUMERIC        = "fr_FR.UTF-8";
      LC_PAPER          = "fr_FR.UTF-8";
      LC_TELEPHONE      = "fr_FR.UTF-8";
      LC_TIME           = "fr_FR.UTF-8";
    };

    services.xserver.xkb = {
      layout  = "fr";
      variant = "azerty";
    };

    console.keyMap = "fr";
  };
}
