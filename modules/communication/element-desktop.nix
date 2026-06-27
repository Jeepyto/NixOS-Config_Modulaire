{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.communication.element;
in
{
  options.tx.communication.element.enable = mkEnableOption "Element (client Matrix)";

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.element-desktop ];
  };
}
