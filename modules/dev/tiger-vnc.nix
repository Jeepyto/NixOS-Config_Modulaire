{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.dev.tigervnc;
in
{
  options.tx.dev.tigervnc.enable = mkEnableOption "TigerVNC";

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.tigervnc ];
  };
}
