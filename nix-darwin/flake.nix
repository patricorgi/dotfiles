{
  description = "corgi flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
    borders = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    # tmux-fingers = {
    #   url = "github:morantron/homebrew-tmux-fingers";
    #   flake = false;
    # };
  };
  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      aerospace,
      borders,
      # tmux-fingers,
      ...
    }:
    let
      pkgs-unstable = nixpkgs-unstable.legacyPackages.aarch64-darwin;
      configuration =
        {
          pkgs,
          pkgs-unstable,
          config,
          ...
        }:
        let
          lazygit = pkgs.lazygit.overrideAttrs {
            version = "0.43.1";
            src = pkgs.fetchFromGitHub {
              owner = "jesseduffield";
              repo = "lazygit";
              rev = "71ad3fac63a3ef3326021837b49e9497d332818b";
              hash = "sha256-iFx/ffaijhOqEDRW1QVzhQMvSgnS4lKFOzq1YdlkUzc=";
            };
            ldflags = [
              "-X main.version=0.43.1"
              "-X main.buildSource=nix"
            ];
          };
        in
        {
          imports = [ ./modules/brew.nix ];

          nixpkgs.config.allowUnfree = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.mkalias
            pkgs.root
            pkgs.rustc
            pkgs.cargo
            lazygit
          ];
          environment.variables = {
            XDG_CONFIG_HOME = "$HOME/.config";
            PAGER = "bat";
            EDITOR = "nvim";
            BAT_THEME = "Catppuccin Mocha";
            LC_ALL = "en_US.UTF-8";
            XRD_LOGLEVEL = "Error";
          };

          fonts.packages = [
            (pkgs.nerdfonts.override {
              fonts = [
                "JetBrainsMono"
                "NerdFontsSymbolsOnly"
              ];
            })
          ];

          system.activationScripts.applications.text =
            let
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
                NSWindowShouldDragOnGesture = 1;
                NSAutomaticWindowAnimationsEnabled = 0;
                KB_DoubleQuoteOption = "\"abc\"";
                KB_SingleQuoteOption = "'abc'";
                NSUserQuotesArray = [
                  "\""
                  "\""
                  "'"
                  "'"
                ];
              };
              # expose
              "com.apple.dock" = {
                showAppExposeGestureEnabled = 1;
                "expose-group-apps" = 1;
              };
              "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
                TrackpadThreeFingerVertSwipeGesture = 0;
              };

              "org.m0k.transmission" = {
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
        specialArgs = {
          inherit pkgs-unstable;
        };
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.patricorgi = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit pkgs-unstable;
            };
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
                "FelixKratz/formulae" = borders;
                # "morantron/tmux-fingers" = tmux-fingers;
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
