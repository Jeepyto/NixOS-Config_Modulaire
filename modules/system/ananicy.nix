{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.services.ananicy;
in
{
  options.tx.system.services.ananicy.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Ananicy-cpp avec les règles CachyOS (priorisation process auto).";
  };

  config = mkIf cfg.enable {
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;

      settings.cgroup_realtime_workaround = lib.mkForce false;
    };

    systemd.services.ananicy-cpp.serviceConfig.Delegate = "cpu cpuset io memory pids";
  };
}
