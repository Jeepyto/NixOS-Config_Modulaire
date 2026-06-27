{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.programs.fish;
in
{
  options.tx.programs.fish = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Shell fish";
    };
  };

  config = mkIf cfg.enable {
    programs.fish.enable = true;

    programs.fish.interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';
  };
}
