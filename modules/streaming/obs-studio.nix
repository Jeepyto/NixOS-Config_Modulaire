{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.streaming.obsStudio;
in
{
  options.tx.streaming.obsStudio.enable = mkEnableOption "OBS Studio";

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-vkcapture
        obs-pipewire-audio-capture
        obs-vaapi
      ];
    };
  };
}
