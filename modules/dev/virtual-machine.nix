{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.dev.virtualMachine;
in
{
  options.tx.dev.virtualMachine.enable = mkEnableOption "Virtual-Machine";

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;        
      };
    };

    virtualisation.spiceUSBRedirection.enable = true;

    environment.systemPackages = with pkgs; [
      virt-manager
      virtio-win
      spice
      spice-gtk
      spice-protocol
    ];

    users.users.jeepy.extraGroups = [ "libvirtd" ];

    services.avahi.enable = mkDefault true;
  };
}