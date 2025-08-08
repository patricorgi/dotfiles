{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    shellIntegration.enableBashIntegration = true;
    darwinLaunchOptions = [
      "--single-instance"
      "--listen-on=unix:/tmp/my-kitty-socket"
    ];
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 24;
      package = (
        (pkgs.nerdfonts.override {
          fonts = [
            "JetBrainsMono"
            "NerdFontsSymbolsOnly"
          ];
        })
      );
    };
    settings = {
      allow_remote_control = true;
      box_drawing_scale = "0.5, 1.2, 1.5, 2";
      copy_on_select = true;
      click_interval = "-1.0";
      disable_ligatures = "cursor";
      hide_window_decorations = "titlebar-only";
      dynamic_background_opacity = false;
      window_padding_width = 10;
      background_opacity = "1.0";
      background_blur = 64;
      macos_option_as_alt = true;
      cursor_trail = 200;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 20;
      cursor_blink_interval = 0;
      detect_urls = false;
      mouse_hide_wait = "0.5";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      "symbol_map U+4E00-U+9FFF,U+3400-U+4DBF" = "Maple Mono NF CN";
      "symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0" =
        "Symbols Nerd Font Mono";
      "font_features JetBrainsMonoNFM-Regular" = "+cv12 +cv18";
      "font_features JetBrainsMonoNFM-SemiBold" = "+cv12 +cv18";
      "font_features JetBrainsMonoNFM-Italic" = "+ss02 +cv12 +cv16 +cv18 +cv19 +cv20";
      "font_features JetBrainsMonoNFM-SemiBoldItalic" = "+ss02 +cv12 +cv16 +cv18 +cv19 +cv20";
      foreground = "#CDD6F4";
      background = "#1E1E2E";
      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";
      cursor = "#F5E0DC";
      cursor_text_color = "#1E1E2E";
      url_color = "#F5E0DC";
      active_border_color = "#B4BEFE";
      inactive_border_color = "#6C7086";
      bell_border_color = "#F9E2AF";
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";
      active_tab_foreground = "#1E1E2E";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#1E1E2E";
      mark1_foreground = "#1E1E2E";
      mark1_background = "#B4BEFE";
      mark2_foreground = "#1E1E2E";
      mark2_background = "#CBA6F7";
      mark3_foreground = "#1E1E2E";
      mark3_background = "#74C7EC";
      color0 = "#45475A";
      color8 = "#585B70";
      color1 = "#F38BA8";
      color9 = "#F38BA8";
      color2 = "#A6E3A1";
      color10 = "#A6E3A1";
      color3 = "#F9E2AF";
      color11 = "#F9E2AF";
      color4 = "#89B4FA";
      color12 = "#89B4FA";
      color5 = "#F5C2E7";
      color13 = "#F5C2E7";
      color6 = "#94E2D5";
      color14 = "#94E2D5";
      color7 = "#BAC2DE";
      color15 = "#A6ADC8";
    };
    keybindings = {
      "cmd+f" = "no_op";
      "alt+shift+h" = "no_op";
      "alt+shift+l" = "no_op";
      "ctrl+shift+r" = "no_op";
      "cmd+enter" = "no_op";
      "ctrl+shift+1" = "goto_tab 1";
      "ctrl+shift+2" = "goto_tab 2";
      "ctrl+shift+3" = "goto_tab 3";
      "ctrl+shift+4" = "goto_tab 4";
      "ctrl+shift+5" = "goto_tab 5";
      "ctrl+shift+6" = "goto_tab 6";
      "ctrl+shift+7" = "goto_tab 7";
      "ctrl+shift+8" = "goto_tab 8";
      "ctrl+shift+9" = "goto_tab 9";
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+n" = "new_os_window";
      "ctrl+shift+o" = "next_layout";
      "ctrl+shift+f" = "show_scrollback";
      "ctrl+shift+h" = "neighboring_window left";
      "ctrl+shift+j" = "neighboring_window down";
      "ctrl+shift+k" = "neighboring_window up";
      "ctrl+shift+l" = "neighboring_window right";
      "ctrl+shift+z" = "toggle_layout stack";
      "cmd+1" = "combine : send_key ctrl+space : send_key 1";
      "cmd+2" = "combine : send_key ctrl+space : send_key 2";
      "cmd+3" = "combine : send_key ctrl+space : send_key 3";
      "cmd+4" = "combine : send_key ctrl+space : send_key 4";
      "cmd+5" = "combine : send_key ctrl+space : send_key 5";
      "cmd+6" = "combine : send_key ctrl+space : send_key 6";
      "cmd+7" = "combine : send_key ctrl+space : send_key 7";
      "cmd+8" = "combine : send_key ctrl+space : send_key 8";
      "cmd+9" = "combine : send_key ctrl+space : send_key 9";
      "cmd+t" = "combine : send_key ctrl+space : send_key c";
      "cmd+w" = "combine : send_key ctrl+space : send_key x";
      "ctrl+shift+[" = "combine : send_key ctrl+space : send_key {";
      "ctrl+shift+]" = "combine : send_key ctrl+space : send_key }";
      "cmd+shift+w" = "combine : send_key ctrl+space : send_key w";
      "cmd+n" = "combine : send_key ctrl+space : send_key \"";
      "cmd+shift+n" = "combine : send_key ctrl+space : send_key %";
      "cmd+z" = "combine : send_key ctrl+space : send_key z";
      "cmd+s" = "send_text all \\e:w\\r";
      "cmd+/" = "combine : send_key space : send_key /";
      "cmd+shift+s" = "send_text all \\e\\e:Telescope lsp_document_symbols \\r";
      "cmd+g" = "send_text all \\e:LazyGitCurrentFile\\r";
      "cmd+shift+g" = "send_text all \\e\\e:Telescope git_submodules\\r";
      "cmd+shift+r" = "send_text all \\e\\e:OverseerQuickAction\\r";
      "cmd+p" = "send_text all :Telescope find_files\\r";
      "cmd+o" = "send_text all :Telescope find_files\\r";
      "cmd+shift+f" = "send_text all :Telescope live_grep_args\\r";
      "cmd+b" = "send_text all :Neotree toggle\\r";
    };
  };
}
