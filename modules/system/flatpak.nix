{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.flatpak;
in
{
  options.tx.system.flatpak.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Support Flatpak + dépôt Flathub.";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    systemd.services.flatpak-repo = {
      description = "Ajoute le dépôt Flathub";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ config.services.flatpak.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}