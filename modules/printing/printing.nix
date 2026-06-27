{ config, lib, ... }:

with lib;

let
  cfg = config.tx.system.services.printing;
in
{
  options.tx.system.services.printing.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Service d'impression CUPS.";
  };

  config = mkIf cfg.enable {
    services.printing.enable = true;
  };
}
