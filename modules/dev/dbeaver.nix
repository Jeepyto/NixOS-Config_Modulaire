{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.dev.dbeaver;
in
{
  options.tx.dev.dbeaver.enable = mkEnableOption "DBeaver";

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.dbeaver-bin ];
  };
}
