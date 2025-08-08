# home.nix
# home-manager switch

{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ./modules/bash.nix
    ./modules/kitty.nix
    ./modules/fzf.nix
  ];
  home.username = "patricorgi";
  home.homeDirectory = "/Users/patricorgi";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Makes sense for user specific applications that shouldn't be available system-wide
  home.packages =
    (with pkgs; [
      pdf2svg
      nodejs_22
      typst
      typstyle
      nixfmt-rfc-style
      newsboat
      ffmpeg
      ffmpegthumbnailer
      imagemagick
      htop
      sshfs-fuse
      bat
      tmux
    ])
    ++ (with pkgs-unstable; [
      neovim
      yazi
    ]);
  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];
  home.sessionVariables = { };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # ".bashrc".source = ~/dotfiles/.bashrc;
    # ".bash_profile".source = ~/dotfiles/.bash_profile;
    ".inputrc".source = ~/dotfiles/.inputrc;
    ".tmux.conf".source = ~/dotfiles/.tmux.conf;
    ".config/starship.toml".source = ~/dotfiles/.config/starship.toml;
    ".config/nvim".source = ~/dotfiles/.config/nvim;
    ".config/tmux".source = ~/dotfiles/.config/tmux;
    ".config/sioyek".source = ~/dotfiles/.config/sioyek;
    ".config/yazi".source = ~/dotfiles/.config/yazi;
    ".config/jellyfin".source = ~/dotfiles/.config/jellyfin;
    ".config/lazygit".source = ~/dotfiles/.config/lazygit;
    ".config/bat".source = ~/dotfiles/.config/bat;
    ".config/newsboat".source = ~/dotfiles/.config/newsboat;
    ".config/aerospace".source = ~/dotfiles/.config/aerospace;
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableTransience = true;
  };
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--glob=!.output"
      "--glob=!.ccache"
      "--glob=!utils/"
      "--glob=!*.bin"
      "--glob=!**/build.*/*"
      "--glob=!**/InstallArea/*"
      "--glob=!**/.git"
      "--glob=!**/ReleaseNotes/*"
      "--glob=!**/*.notes"
      "--glob=!**/*.rst"
      "--glob=!**/*.png"
      "--glob=!**/*.pdf"
      "--glob=!**/*.svg"
      "--glob=!**/*.root"
      "--glob=!**/*.f"
      "--glob=!**/*.opts"
      "--glob=!**/*.bat"
      "--glob=!**/*.pyc"
      "--glob=!**/*.cmake"
      "--glob=!**/*.cls"
      "--glob=!**/*.gdml"
      "--glob=!**/logs/[0-9][0-9][0-9][0-9][0-9][0-9]"
      "--glob=!**/*.hpp"
      "--glob=!**/*.cfg"
      "--glob=!**/*.mx"
      "--glob=!**/*.bbdt"
      "--glob=!**/*\.ref.*"
      "--glob=!**/release.notes*"
      "--glob=!Geant4/CHANGELOG/ReleaseNotes*"
    ];
  };
  programs.ruff = {
    enable = true;
    settings = {
      lint = {
        ignore = [
          "E402"
          "F403"
          "F405"
        ];
      };
    };
  };
  programs.eza.enable = true;
  programs.yt-dlp = {
    enable = true;
    settings = {
      cookies-from-browser = "safari";
      format = "ba+bv";
    };
  };
  programs.mpv = {
    enable = true;
    config = {
      screenshot-directory = "~/Desktop";
      autofit-larger = "90%x90%";
      ontop = true;
    };
    bindings = {
      j = "seek -5";
      l = "seek 5";
      J = "seek -5 relative-percent";
      L = "seek 5 relative-percent";
      "[" = "add speed -0.1";
      "]" = "add speed 0.1";
      "=" = "set speed 1.0";
      I = "script-binding stats/display-stats";
      UP = "add volume 5";
      i = "add volume 5";
      k = "add volume -5";
      c = "cycle sub-visibility";
    };
  };

  programs.home-manager.enable = true;
}
