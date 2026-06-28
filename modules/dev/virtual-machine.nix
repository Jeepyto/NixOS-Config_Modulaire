{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.dev.virtualMachine;

  defaultNetworkXml = pkgs.writeText "libvirt-default-network.xml" ''
    <network>
      <name>default</name>
      <forward mode="nat"/>
      <bridge name="virbr0" stp="on" delay="0"/>
      <ip address="192.168.122.1" netmask="255.255.255.0">
        <dhcp>
          <range start="192.168.122.2" end="192.168.122.254"/>
        </dhcp>
      </ip>
    </network>
  '';
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

    users.users.jeepy.extraGroups = [ "kvm" "libvirtd" ];

    services.avahi.enable = mkDefault true;
    
    systemd.services.libvirtd-default-network = {
      description = "Define and start libvirt default NAT network";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ pkgs.libvirt ];
      script = ''
        if ! virsh net-info default >/dev/null 2>&1; then
          virsh net-define ${defaultNetworkXml}
        fi
        if ! virsh net-info default 2>/dev/null | grep -q "^Active:.*yes"; then
          virsh net-start default
        fi
        virsh net-autostart default
      '';
    };
  };
}