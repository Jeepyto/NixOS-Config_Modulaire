{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.dev.anydesk;
in
{
  options.tx.dev.anydesk.enable = mkEnableOption "AnyDesk";

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.anydesk ];
  };
}