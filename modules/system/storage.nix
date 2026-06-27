{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.storage;
in
{
  options.tx.system.storage = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Scheduler I/O kyber/bfq, TRIM périodique, ZRAM swap, règles udev (DualSense, etc).";
    };

    zramMemoryPercent = mkOption {
      type = types.int;
      default = 100;
      description = "Pourcentage de la RAM alloué au swap compressé ZRAM.";
    };
  };

  config = mkIf cfg.enable {
    hardware.block = {
      defaultScheduler           = "kyber";
      defaultSchedulerRotational = "bfq";
    };

    services.fstrim.enable = true;

    zramSwap = {
      enable        = mkDefault true;
      algorithm     = "zstd";
      memoryPercent = mkDefault cfg.zramMemoryPercent;
      priority      = 100;
    };

    # Règles udev
    services.udev.extraRules = ''
      ACTION=="change", KERNEL=="zram0", ATTR{initstate}=="1", SYSCTL{vm.swappiness}="150", RUN+="/bin/sh -c 'echo N > /sys/module/zswap/parameters/enabled'"
      ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';
  };
}
