{ config, pkgs, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    initExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(/usr/libexec/path_helper)"
    '';
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      VISUAL = "nvim";
      BAT_THEME = "Catppuccin Mocha";
      LC_ALL = "en_US.UTF-8";
      XRD_LOGLEVEL = "Error";
    };
    shellAliases = {
      nixup = "darwin-rebuild switch --flake ~/dotfiles/nix-darwin#16Pro --impure";
      b = "bat";
      l = "less";
      cf = "cd ~/dotfiles";
      lh = "eza --sort newest --group --long --icons";
      ll = "eza --sort Name --long --icons";
      lg = "lazygit";
      v = "nvim";
      vh = "nvim ~/dotfiles/nix-darwin/home.nix";
      vn = "nvim ~/dotfiles/nix-darwin/flake.nix";
      vk = "nvim ~/.config/kitty/kitty.conf";
      vs = "nvim ~/.ssh/config";
      vt = "nvim ~/.tmux.conf";
      p = "python3";
      rp = "realpath";
      t = "type";
      tm = "tmux new -A -s main";
      rs = "rsync -avh --progress --stats";
      ht = "htop -u $USER";
      dirsize = "du -hs .";
      cpu = "ps -eo user,cmd:120,%cpu --sort=+%cpu";
      mem = "ps -eo user,cmd:120,%mem --sort=+%mem";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
    };
  };
}
