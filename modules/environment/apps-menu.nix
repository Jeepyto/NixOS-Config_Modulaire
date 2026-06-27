{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.tx.appsMenu;
  aplEntry = name: position:
    lib.gvariant.mkDictionaryEntry name
      (lib.gvariant.mkVariant [
        (lib.gvariant.mkDictionaryEntry "position" (lib.gvariant.mkVariant (lib.gvariant.mkInt32 position)))
      ]);
in
{
  options.tx.appsMenu.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Range les icônes du menu d'applications GNOME en dossiers thématiques (Gaming, Dev, Studio...).";
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/shell".app-picker-layout = [
            [
              (aplEntry "Systeme" 0)
              (aplEntry "Utilitaires" 1)
              (aplEntry "Bureautique" 2)
              (aplEntry "Gaming" 3)
            ]
          ];
          "org/gnome/desktop/app-folders".folder-children = [
            "Systeme"
            "Utilitaires"
            "Bureautique"
            "Gaming"
          ];

          "org/gnome/desktop/app-folders/folders/Gaming" = {
            name = "Gaming";       
            translate = false;     
            apps = [
              "faugus-launcher.desktop"
              "winetricks.desktop"
            ];
          };

          "org/gnome/desktop/app-folders/folders/Bureautique" = {
            name = "Office.directory";
            translate = true;
            apps = [
              "startcenter.desktop"
              "writer.desktop"
              "calc.desktop"
              "impress.desktop"
              "draw.desktop"
              "math.desktop"
              "base.desktop"
            ];
          };

          "org/gnome/desktop/app-folders/folders/Utilitaires" = {
            name = "X-GNOME-Shell-Utilities.directory";
            translate = true;
            apps = [
              "org.gnome.Calculator.desktop" 
              "org.gnome.TextEditor.desktop"
              "cups.desktop"
              "org.gnome.seahorse.Application.desktop"
              "org.gnome.FileRoller.desktop"
              "org.gnome.Papers.desktop"
              "org.gnome.Loupe.desktop"
              "vlc.desktop"           
            ];
          };

          "org/gnome/desktop/app-folders/folders/Systeme" = {
            name = "X-GNOME-Shell-System.directory";
            translate = true;
            apps = [
              "btop.desktop"
              "org.gnome.SystemMonitor.desktop"
              "org.gnome.Extensions.desktop"
              "org.gnome.tweaks.desktop"
              "org.gnome.Settings.desktop"
              "gparted.desktop"
              "org.gnome.DiskUtility.desktop"
              "trcc-linux.desktop" 
            ];
          };
        };
      }
    ];
  };
}
