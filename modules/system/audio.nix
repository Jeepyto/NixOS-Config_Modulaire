{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.services.audio;
in
{
  options.tx.system.services.audio.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Base audio PipeWire (remplace PulseAudio, ALSA 32-bit, support Pulse) — sans le filtre micro RNNoise, voir micro-filter.nix.";
  };

  config = mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
