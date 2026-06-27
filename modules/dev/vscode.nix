{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.dev.vscode;

  vscodeWithExtensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = with pkgs.vscode-extensions; [
      ms-ceintl.vscode-language-pack-fr
      jnoortheen.nix-ide
      ms-python.python
      ecmel.vscode-html-css
    ];
  };

  argvJson = pkgs.writeText "vscode-argv.json" ''
    {
        "locale": "fr"
    }
  '';
in
{
  options.tx.dev.vscode.enable = mkOption {
    type = types.bool;
    default = true;
    description = "VS Code avec extensions (FR, Nix IDE, Python, HTML/CSS)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ vscodeWithExtensions ];

    system.activationScripts.vscodeArgvJson = {
      text = ''
        mkdir -p /home/jeepy/.vscode
        if [ ! -e /home/jeepy/.vscode/argv.json ]; then
          cp ${argvJson} /home/jeepy/.vscode/argv.json
          chown jeepy:users /home/jeepy/.vscode/argv.json
          chmod u+w /home/jeepy/.vscode/argv.json
        fi
      '';
    };
  };
}
