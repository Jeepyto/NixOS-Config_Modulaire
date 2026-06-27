{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.kernel;
in
{
  options.tx.system.kernel = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Kernel CachyOS + modules ntsync/tcp_bbr + sysctl mémoire/réseau orientés gaming.";
    };

    swappiness = mkOption {
      type = types.int;
      default = 100;
      description = "vm.swappiness — gardé haut car le swap est en ZRAM (compressé en RAM).";
    };

    tcpCongestionControl = mkOption {
      type = types.enum [ "bbr" "cubic" "reno" ];
      default = "bbr";
      description = "net.ipv4.tcp_congestion_control — algorithme de contrôle de congestion TCP.";
    };
  };

  config = mkIf cfg.enable {
    # Kernel CachyOS
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts; 

    boot.kernelModules = [ "ntsync" "tcp_bbr" ];

    boot.kernelParams = [ "amd_pstate=active" ];

    boot.kernel.sysctl = {
      # MÉMOIRE
      "vm.swappiness"                = cfg.swappiness;
      "vm.vfs_cache_pressure"        = 50;
      "vm.dirty_bytes"               = 268435456;
      "vm.dirty_background_bytes"    = 67108864;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.page-cluster"              = 0;
      "vm.max_map_count"             = 16777216;

      # KERNEL
      "kernel.split_lock_mitigate" = 0;
      "kernel.nmi_watchdog"        = 0;
      "kernel.printk"              = "3 3 3 3";
      "kernel.kptr_restrict"       = 2;
      "kernel.kexec_load_disabled" = 1;
      "kernel.sched_rt_runtime_us" = 950000;

      # RÉSEAU
      "net.core.default_qdisc"             = "cake";
      "net.ipv4.tcp_congestion_control"    = cfg.tcpCongestionControl;
      "net.ipv4.tcp_fastopen"              = 3;
      "net.ipv4.tcp_mtu_probing"           = 1;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_tw_reuse"              = 1;
      "net.core.netdev_max_backlog"        = 16384;
      "net.core.somaxconn"                 = 8192;
    };
  };
}
