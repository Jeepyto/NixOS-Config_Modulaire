{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tx.configuration.mangohudConfig;

  mangohudConfTemplate = pkgs.writeText "MangoHud.conf" ''
    legacy_layout=0
    horizontal
    background_alpha=0.0
    round_corners=0
    background_color=000000
    font_size=24
    text_color=FFFFFF
    position=top-left
    offset_x=700
    offset_y=10
    toggle_hud=Shift_R+F12
    hud_compact
    gpu_list=0
    table_columns=3
    gpu_text=GPU
    gpu_stats
    gpu_load_change
    gpu_load_value=50,90
    gpu_load_color=FFFFFF,FFAA7F,CC0000
    vram
    vram_color=AD64C1
    gpu_temp
    gpu_color=2E9762
    cpu_text=CPU
    cpu_stats
    cpu_load_change
    cpu_load_value=50,90
    cpu_load_color=FFFFFF,FFAA7F,CC0000
    cpu_temp
    cpu_color=2E97CB
    ram
    ram_color=C26693
    fps
    frame_timing
    frametime_color=00FF00
    fps_limit_method=late
    toggle_fps_limit=Shift_L+F1
    fps_limit=0
    gamemode
    vsync=4
    fps_color_change
    fps_color=B22222,FDFD09,39F900
    fps_value=30,60
    custom_text=-
    exec=echo "NixOS | $(uname -r)"
    output_folder=/home/jeepy/.local/share/mangohud-logs
    log_duration=30
    log_interval=100
    toggle_logging=Shift_L+F2
    blacklist=zenity,protonplus,lsfg-vk-ui,bazzar,gnome-calculator,pamac-manager,lact,ghb,bitwig-studio,ptyxis,yumex,gnome-calculator
  '';

  mangohudUserConfigPath = "/home/jeepy/.config/MangoHud/MangoHud.conf";
in
{
  options.tx.configuration.mangohudConfig.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Paquet MangoHud + fichier de config";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mangohud ];

    system.activationScripts.mangohudUserConfig = {
      text = ''
        mkdir -p $(dirname ${mangohudUserConfigPath})
        if [ ! -e "${mangohudUserConfigPath}" ]; then
          cp ${mangohudConfTemplate} "${mangohudUserConfigPath}"
          chown jeepy:users "${mangohudUserConfigPath}"
          chmod u+w "${mangohudUserConfigPath}"
        fi
      '';
    };
  };
}