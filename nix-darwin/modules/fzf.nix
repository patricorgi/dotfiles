{ config, pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "rg --files";
    fileWidgetCommand = "rg --files";
    fileWidgetOptions = [ "--preview 'head {}'" ];
    colors = {
      "bg+" = "#313244";
      bg = "#1e1e2e";
      spinner = "#f5e0dc";
      hl = "#f38ba8";
      fg = "#cdd6f4";
      header = "#f38ba8";
      info = "#cba6f7";
      pointer = "#f5e0dc";
      marker = "#f5e0dc";
      "fg+" = "#cdd6f4";
      prompt = "#cba6f7";
      "hl+" = "#f38ba8";
    };
  };
}
