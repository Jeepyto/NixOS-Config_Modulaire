{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.services.ananicyPolkit;
in
{
  options.tx.system.services.ananicyPolkit.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Règle polkit autorisant jeepyto à gérer ananicy-cpp.service sans mot de passe.";
  };

  config = mkIf cfg.enable {
    security.polkit.extraConfig = ''
      polkit.addRule(function (action, subject) {
        if (
          action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "ananicy-cpp.service" &&
          subject.user == "jeepy"
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
