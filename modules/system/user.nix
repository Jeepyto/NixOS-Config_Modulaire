{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.user;
in
{
  options.tx.system.user.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Compte utilisateur principal jeepyto (groupes networkmanager + wheel, shell fish).";
  };

  config = mkIf cfg.enable {
    users.users."jeepy" = {
      isNormalUser = true;
      description  = "Jeepyto Sajkrohn";
      extraGroups  = [ "networkmanager" "wheel" ];
      shell        = pkgs.fish;
    };
  };
}
