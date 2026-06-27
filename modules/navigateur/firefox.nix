{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.navigateur.firefox;
in
{
  options.tx.navigateur.firefox.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Firefox (module NixOS système) avec pack de langue FR.";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [ "fr" ];
      preferences = {
        "intl.locale.requested" = "fr";
      };
    };
  };
}
