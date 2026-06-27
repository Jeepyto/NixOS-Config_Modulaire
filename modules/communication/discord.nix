{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.communication.discord;
  discordWrapped = pkgs.symlinkJoin {
    name = "discord-wrapped-${pkgs.discord.version}";
    paths = [ pkgs.discord ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/discord \
        --add-flags "--skip-host-update"
    '';
  };
in
{
  options.tx.communication.discord.enable = mkEnableOption "Discord";

  config = mkIf cfg.enable {
    environment.systemPackages = [ discordWrapped ];
  };
}
