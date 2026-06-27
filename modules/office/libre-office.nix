{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.office.libreOffice;
in
{
  options.tx.office.libreOffice.enable = mkEnableOption "Libre-Office";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libreoffice-fresh
      hunspell
      hunspellDicts.fr-any
    ];
  };
}
