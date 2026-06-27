{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.environnement.gnome;
  cfgSettings = config.tx.configuration.gnomeSettings;
in
{
  options.tx.environnement.gnome = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Session GNOME (GDM, extensions, paquets exclus/inclus, autologin jeepyto).";
    };

    autoLogin = mkOption {
      type = types.bool;
      default = true;
      description = "Connexion automatique de jeepyto au démarrage.";
    };
  };

  options.tx.configuration.gnomeSettings.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Préférences dconf GNOME (favoris du dock, extensions, thème d'icônes, comportement des fenêtres) — via programs.dconf.profiles.user, module NixOS natif.";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.xserver.enable = true;

      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      services.xserver.excludePackages = [ pkgs.xterm ];
      services.gnome.gnome-browser-connector.enable = true;

      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-music
        gnome-maps
        gnome-weather
        gnome-connections
        gnome-contacts
        gnome-characters
        gnome-clocks
        gnome-font-viewer
        gnome-logs
        simple-scan
        epiphany
        showtime
        decibels
        baobab
        gnome-user-share
        yelp
        snapshot
        gnome-calendar
      ];

      environment.systemPackages = with pkgs; [
        gnome-tweaks
        gnomeExtensions.caffeine
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.quick-settings-audio-panel
        gnomeExtensions.vitals
        gnomeExtensions.bluetooth-battery-meter
        iconpack-obsidian
        file-roller
        git
        btop
        vlc
        mesa-demos
        winetricks
      ];

      documentation.nixos.enable = false;

      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;

      services.displayManager.autoLogin = mkIf cfg.autoLogin {
        enable = true;
        user = "jeepy";
      };

      programs.dconf.enable = true;

      programs.dconf.profiles.gdm.databases = [{
        settings = {
          "org/gnome/desktop/peripherals/keyboard" = {
            numlock-state = true;
          };
        };
      }];
      programs.dconf.profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/peripherals/keyboard" = {
            numlock-state = true;
          };
        };
      }];
    })

    (mkIf cfgSettings.enable {
      # programs.dconf.profiles.user est un vrai module NixOS (pas home-manager) :
      # https://wiki.nixos.org/wiki/GNOME#Declarative_dconf_configuration
      programs.dconf.profiles.user.databases = [
        {
          settings = {
            "org/gnome/shell" = {
              favorite-apps = [
                "firefox.desktop"
                "com.obsproject.Studio.desktop"
                "element-desktop.desktop"
                "discord.desktop"
                "steam.desktop"
                "code.desktop"
                "dbeaver.desktop"
                "vncviewer.desktop"
                "virt-manager.desktop"
                "blender.desktop"
                "org.freecad.FreeCAD.desktop"
                "org.gnome.Nautilus.desktop"
                "org.gnome.Console.desktop"
              ];
              disable-user-extensions = false;
              enabled-extensions = [
                "caffeine@patapon.info"
                "appindicatorsupport@rgcjonas.gmail.com"
                "dash-to-dock@micxgx.gmail.com"
                "quick-settings-audio-panel@rayzeq.github.io"
                "Vitals@CoreCoding.com"
                "Bluetooth-Battery-Meter@maniacx.github.com"
              ];
            };
            "org/gnome/desktop/interface" = {
              icon-theme = "Obsidian";
            };
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
              focus-mode = "click";
              visual-bell = false;
            };
          };
        }
      ];
    })
  ];
}
