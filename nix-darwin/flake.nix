{
  description = "corgi flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
        homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, aerospace, ...}:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.mkalias
          pkgs.neovim
          pkgs.starship
          pkgs.tmux
          pkgs.newsboat
          pkgs.lazygit
          pkgs.yt-dlp
          pkgs.rustup
          pkgs.ffmpeg
          pkgs.ffmpegthumbnailer
          pkgs.stow
          pkgs.zoxide
          pkgs.yazi
          pkgs.imagemagick
          pkgs.pdf2svg
          pkgs.htop
          pkgs.nodejs_22
          pkgs.eza
          pkgs.ripgrep
          pkgs.sshfs-fuse
          pkgs.fzf
          pkgs.typst
          pkgs.typstyle
          pkgs.mpv
        ];

      homebrew = {
        enable = true;
        casks = [
          "arc"
          "jordanbaird-ice"
          "lyricsx"
          "chatgpt"
          # "tigervnc-viewer"
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
          "aerospace"
          "alfred"
          "sf-symbols"
          "zotero"
          "macfuse"
          "keyboard-maestro"
        ];
        brews = [
          "php"
          "mas"
        ];
        masApps = {
          "Dark Reader for Safari" = 1438243180;
          "Yoink" = 457622435;
          "Things 3" = 904280696;
          "PDF Experts" = 1055273043;
          "Money Pro" = 972572731;
          "Pixelmator Pro" = 1289583905;
          "Hush Nag Blocker" = 1544743900;
          # "Reeder" = 1529448980;
          "RunCat" = 1429033973;
          "Final Cut Pro" = 424389933;
          "Compressor" = 424390742;
          "Motion" = 434290957;
          "Mouse Gestures for Safari" = 1618804075;
          "AdGuard for Safari" = 1440147259;
          "TamperMonkey for Safari" = 1482490089;
          "Microsoft Word" =  462054704;
          "Microsoft Excel" = 462058435;
          "Microsoft PowerPoint" = 462062816;
          "Vimlike" = 1584519802;
          "Pages" = 409201541;
          "Numbers" = 409203825;
          "Keynotes" = 409183694;
        };
        onActivation.cleanup = "zap";
        taps = builtins.attrNames config.nix-homebrew.taps;
      };

      fonts.packages = [
        (pkgs.nerdfonts.override { fonts = [ 
					   "JetBrainsMono"
					   "NerdFontsSymbolsOnly" ]; })
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';
      users.users.patricorgi.home = "/Users/patricorgi";
      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      system.startup.chime = false;
      security.pam.enableSudoTouchIdAuth = true;
      system.defaults = {
        dock.autohide = true;
        dock.autohide-time-modifier = 0.0;
        dock.autohide-delay = 0.0;
        dock.persistent-apps = [
          "/System/Applications/Calendar.app"
          "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
          "/System/Applications/Mail.app"
          "/Applications/Things3.app"
          "/Applications/kitty.app"
        ];
	dock.mru-spaces = true;
	dock.show-recents = false;
        loginwindow.GuestEnabled = false;
	finder.FXPreferredViewStyle = "clmv";
	finder.FXDefaultSearchScope = "SCcf";
	finder.ShowPathbar = true;
	NSGlobalDomain.KeyRepeat = 2;
	NSGlobalDomain.InitialKeyRepeat = 15;
	NSGlobalDomain.AppleTemperatureUnit = "Celsius";
	screencapture.disable-shadow = true;
	screencapture.type = "jpg";
	screencapture.location = "~/Downloads";
	trackpad.Clicking = true;
	trackpad.TrackpadThreeFingerDrag = true;
        CustomUserPreferences = {
          "com.apple.Siri".StatusMenuVisible = false;
          "NSGlobalDomain" = {
            "com.apple.sound.beep.feedback" = 1;
            AppleReduceDesktopTinting = 1;
          };
          # expose
          "com.apple.dock" = {
            showAppExposeGestureEnabled = 1;
            "expose-group-apps" = 1;
          };
          "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
            TrackpadThreeFingerVertSwipeGesture = 0;
          };

          "org.m0k.transmission" =     {
            AutoSize = 1;
            CheckQuit = 0;
            CheckUpload = 1;
            UploadLimit = 0;
            AutoImport = 1;
            SpeedLimitUploadLimit = 0;
            DeleteOriginalTorrent = 1;
            DownloadAsk = 0;
            DownloadLocationConstant = 1;
            MagnetOpenAsk = 0;
            Sort = "Date";
          };
          ZoomChat = {
            ZoomShowIconInMenuBar = false;
          };
          "us.zoom.xos.Hotkey" = {
            "[HK@combo]-HotkeyAcceptCall" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyCreateClip" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyDeclineCall" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyEndCall" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyFullScreen" = {
                "hot key code" = 3;
                "hot key modifier" = 1310720;
            };
            "[HK@combo]-HotkeyGainRemoteControl" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyHoldCall" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyInitiateCall" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyJoinMeeting" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyMeetingControl" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyMuteCall" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOffAllAudio" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOnAllAudio" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOnInvite" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOnOffAudio" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOnOffCloudRecord" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOnOffLocalRecord" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOnOffShare" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOnOffVideo" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyOpenMeetingReactionsPanel" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyPauseResumeRecord" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyPauseResumeShare" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyPushToTalk" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyReadAcitiveSpeakerName" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyScheduleMeeting" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyScreenShot" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySendCelebrateReaction" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySendClappingReaction" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySendHeartReaction" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySendJoyReaction" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySendSurpriseReaction" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySendThumbsUpReaction" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyShareScreen" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyShowHideFitbar" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyStartMeeting" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyStopRemoteControl" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySwitchCamera" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySwitchDualMonitors" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeySwitchMinimal" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyToggleHand" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@combo]-HotkeyTransferCall" = {
                "hot key code" = "-1";
                "hot key modifier" = 0;
            };
            "[HK@state]-HotkeyPushToTalk" = 0;
          };
          "com.openai.chat" = {
            desktopAppIconBehavior = "{\"showOnlyInDock\":{}}";
            launchAtLogin = 1;
          };
          "com.stairways.keyboardmaestro.engine" = {
            AlwayShowStatusItem = 0;
          };
          "com.apple.finder" = {
            NewWindowTarget = "PfDe";
            "_FXSortFoldersFirst" = 1;
          };
          "at.EternalStorms.Yoink" = {
            "NSStatusItem Visible Item-0" = 0;
            "ess_userWantsToReviewApp" = 0;
            shouldHideOnLaunch = 0;
            showMenubarIcon = 0;
          };
          "com.culturedcode.ThingsMac" = {
              AppleLanguages = [
                  "en-US"
                  "zh-Hans"
                  "zh-Hans-US"
              ];
          };
          "com.apple.FinalCut" = {
              AppleLanguages = [
                  "en-US"
                  "zh-Hans"
                  "zh-Hans-US"
              ];
          };
          "com.apple.motionapp" = {
              AppleLanguages = [
                  "en-US"
                  "zh-Hans"
                  "zh-Hans-US"
              ];
          };
          "com.apple.Safari" = {
              IncludeDevelopMenu = 1;
              ShowStandaloneTabBar = 0;
          };
          "com.apple.mail" = {
            DisableInlineAttachmentViewing = false;
            AddLinkPreviews = 0;
            SwipeAction = 1; # discard mail to archive
            NewMessagesSoundName = "Funk";
            NSFontSize = 16;
            NSFixedPitchFont = "JetBrainsMonoNFM-Regular";
            NSFixedPitchFontSize = 15;
          };
          "com.apple.controlcenter" = {
              "NSStatusItem Visible Battery" = 0;
              "NSStatusItem Visible BentoBox" = 1;
              "NSStatusItem Visible Clock" = 1;
              "NSStatusItem Visible FocusModes" = 1;
              "NSStatusItem Visible NowPlaying" = 0;
              "NSStatusItem Visible Sound" = 1;
              "NSStatusItem Visible WiFi" = 1;
          };
        };
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      # programs.bash.enable = true;
      # programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#16Pro
    darwinConfigurations."16Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
	home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.patricorgi = import ./home.nix;
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true; 
            # Apple Silicon only
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "patricorgi";

            autoMigrate = false;

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-core" = homebrew-core;
              "nikitabobko/homebrew-tap" = aerospace;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."16Pro".pkgs;
  };
}
