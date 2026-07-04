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
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters          = [ "https://attic.xuyh0120.win/lantian" ];
      trusted-public-keys   = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    };
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "26.05";
  };
}
