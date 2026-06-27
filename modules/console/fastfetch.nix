{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.configuration.fastfetch;

  fastfetchConfig = pkgs.writeText "fastfetch-config.jsonc" (builtins.toJSON {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";
    logo = {
      padding = {
        top = 2;
      };
    };
    modules = [
      "break"
      "break"
      "title"
      "separator"
      "os"
      "host"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "display"
      "de"
      "wm"
      "terminal"
      "cpu"
      "gpu"
      "memory"
      "swap"
      "disk"
      "locale"
      "break"
      "break"
    ];
  });
in
{
  options.tx.configuration.fastfetch.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Fastfetch";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.fastfetch ];

    system.activationScripts.fastfetchConfig = {
      text = ''
        mkdir -p /home/jeepy/.config/fastfetch
        if [ ! -e /home/jeepy/.config/fastfetch/config.jsonc ]; then
          cp ${fastfetchConfig} /home/jeepy/.config/fastfetch/config.jsonc
          chown -R jeepy:users /home/jeepy/.config/fastfetch
          chmod u+w /home/jeepy/.config/fastfetch/config.jsonc
        fi
      '';
    };
  };
}
