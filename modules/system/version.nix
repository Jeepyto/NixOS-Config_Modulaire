{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.version;
in
{
  options.tx.system.version.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Active les expérimentations nix-command/flakes et fixe le stateVersion.";
  };

  config = mkIf cfg.enable {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;
    # stateVersion : date de la première installation, ne pas changer
    system.stateVersion = "26.05";
  };
}
