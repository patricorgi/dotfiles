{ config, pkgs, ... }:
{
  homebrew = {
    enable = true;
    casks = [
      "mac-mouse-fix"
      "downie"
      "arc"
      "jordanbaird-ice"
      "chatgpt"
      "jellyfin"
      "karabiner-elements"
      "obsidian"
      "sioyek"
      "zoom"
      "iina"
      "transmission"
      "kitty"
      "latexit"
      "xquartz"
      "calibre"
      "yacreader"
      "the-unarchiver"
      "qq"
      "wechat"
      "bilibili"
      "1password"
      "1password-cli"
      "tinymediamanager"
      "miniforge"
      "mactex-no-gui"
      "alfred"
      "sf-symbols"
      "zotero"
      "macfuse"
      "keyboard-maestro"
      "aerospace"
      "keycastr"
      "discord"
      "mattermost"
    ];
    brews = [
      "php"
      "mas"
      "yq"
      "exiftool"
      "unar"
      "borders"
    ];
    masApps = {
      "Yoink" = 457622435;
      "Things 3" = 904280696;
      "PDF Experts" = 1055273043;
      "Money Pro" = 972572731;
      "Pixelmator Pro" = 1289583905;
      "Hush Nag Blocker" = 1544743900;
      "RunCat" = 1429033973;
      "Final Cut Pro" = 424389933;
      "Compressor" = 424390742;
      "Motion" = 434290957;
      "Microsoft Word" = 462054704;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Pages" = 409201541;
      "Numbers" = 409203825;
      "Keynotes" = 409183694;
      "Vimkey" = 1585682577;
    };
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    taps = builtins.attrNames config.nix-homebrew.taps;
  };
}
