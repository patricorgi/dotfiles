# home.nix
# home-manager switch 

{ config, pkgs, ... }:

{
  home.username = "patricorgi";
  home.homeDirectory = "/Users/patricorgi";
  home.stateVersion = "24.05"; # Please read the comment before changing.

# Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".bashrc".source = ~/dotfiles/.bashrc;
    ".bash_profile".source = ~/dotfiles/.bash_profile;
    ".inputrc".source = ~/dotfiles/.inputrc;
    ".fzf.bash".source = ~/dotfiles/.fzf.bash;
    ".tmux.conf".source = ~/dotfiles/.tmux.conf;
    ".config/starship.toml".source = ~/dotfiles/.config/starship.toml;
    ".config/nvim".source = ~/dotfiles/.config/nvim;
    ".config/kitty".source = ~/dotfiles/.config/kitty;
    ".config/aerospace".source = ~/dotfiles/.config/aerospace;
    ".config/sioyek".source = ~/dotfiles/.config/sioyek;
    ".config/yazi".source = ~/dotfiles/.config/yazi;
    ".config/jellyfin".source = ~/dotfiles/.config/jellyfin;
    ".config/lazygit".source = ~/dotfiles/.config/lazygit;
    ".config/mpv".source = ~/dotfiles/.config/mpv;
    ".config/newsboat".source = ~/dotfiles/.config/newsboat;
    ".config/ruff".source = ~/dotfiles/.config/ruff;
    ".config/ripgreprc".source = ~/dotfiles/.config/ripgreprc;
    ".config/yt-dlp".source = ~/dotfiles/.config/yt-dlp;
  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
  ];
  programs.home-manager.enable = true;
#   programs.tmux = {
#     enable = true;
#     shell = "/run/current-system/sw/bin/bash";
#     plugins = [
#       {
#         plugin = pkgs.tmuxPlugins.catppuccin;
#         extraConfig = ''
# set -g @catppuccin_flavor 'mocha'
# set -g @catppuccin_window_default_text "#{s|$USER|~|:#{b:pane_current_path}} #{s|rsync|󰓦|;s|yazi|󰇥|;s|python||;s|nvim||;s|bash||;s|htop|󰍛|;s|root|󰞄|;s|lazygit||;s|tmux||:pane_current_command}"
# set -g @catppuccin_window_current_text "#{s|$USER|~|:#{b:pane_current_path}} #{s|rsync|󰓦|;s|yazi|󰇥|;s|python||;s|nvim||;s|bash||;s|htop|󰍛|;s|root|󰞄|;s|lazygit||;s|tmux||:pane_current_command}"
#
# set -g @catppuccin_status_modules_right "memory cpu session host"
# set -g @catppuccin_window_left_separator ""
# set -g @catppuccin_window_right_separator " "
# set -g @catppuccin_window_middle_separator " █"
# set -g @catppuccin_window_number_position "right"
# set -g @catppuccin_status_left_separator  " "
# set -g @catppuccin_status_right_separator ""
# set -g @catppuccin_status_connect_separator "no"
# set -g @catppuccin_window_status_enable "yes"
# set -g @catppuccin_window_status_icon_enable "yes"
#         '';
#       }
#     ];
#   };
}
