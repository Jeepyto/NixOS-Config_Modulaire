{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.network;
in
{
  options.tx.system.network = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "NetworkManager + dnsmasq local en résolveur DNS.";
    };

    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "Nom d'hôte de la machine.";
    };
  };

  config = mkIf cfg.enable {
    networking.hostName = cfg.hostName;

    networking.networkmanager.enable = true;

    services.dnsmasq = {
      enable = true;
      settings = {
        listen-address = "127.0.0.1";
        bind-interfaces = true;
        cache-size = 1000;
        no-resolv = true;
        server = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
      };
    };

    networking.networkmanager.dns = "dnsmasq";
  };
}
