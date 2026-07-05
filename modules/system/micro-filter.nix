{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.system.services.microFilter;
  cfgAudio = config.tx.system.services.audio;
in
{
  options.tx.system.services.microFilter.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Filtre de réduction de bruit RNNoise sur le micro (nécessite tx.system.services.audio.enable).";
  };

  config = mkIf (cfg.enable && cfgAudio.enable) {
    services.pipewire.extraLadspaPackages = [ pkgs.rnnoise-plugin ];

    services.pipewire.configPackages = [
      (pkgs.writeTextDir "share/pipewire/filter-chain.conf.d/99-noise-canceling.conf" ''
        context.modules = [
          {
            name = libpipewire-module-filter-chain
            args = {
              node.description = "Noise Canceling source"
              media.name = "Noise Canceling source"
              filter.graph = {
                nodes = [
                  {
                    type = ladspa
                    name = rnnoise
                    plugin = librnnoise_ladspa
                    label = noise_suppressor_mono
                    control = {
                      "VAD Threshold (%)" = 50.0
                      "VAD Grace Period (ms)" = 200
                      "Retroactive VAD Grace (ms)" = 0
                    }
                  }
                ]
              }
              capture.props = {
                node.name = "capture.rnnoise_source"
                node.passive = true
                audio.rate = 48000
              }
              playback.props = {
                node.name = "rnnoise_source"
                media.class = "Audio/Source"
                audio.rate = 48000
              }
            }
          }
        ]
      '')
    ];
    systemd.user.services.filter-chain.wantedBy = [ "default.target" ];
  };
}
