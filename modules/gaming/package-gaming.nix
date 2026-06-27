{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.gaming.extraPackages;
in
{
  options.tx.gaming.extraPackages = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "outils gaming complémentaires";
    };   
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dualsensectl
      vkbasalt
      vulkan-tools
      umu-launcher
      wineWow64Packages.stable      
    ];
  };
}
