# CachyOS Notes

## Basic Applications And Programs

This is a curated reinstall list based on the current machine's explicit packages, foreign/AUR packages, and pacman install history. It is not a perfect diff against a stock CachyOS KDE install, because CachyOS installs many desktop/system packages as explicit packages.

Check current explicit packages:

```bash
pacman -Qqen   # native explicit packages
pacman -Qqem   # foreign/AUR explicit packages
pacman -Qqet   # explicit packages not required by other packages
```

### Package Helper

Install build tooling and `paru` first if they are not already present:

```bash
sudo pacman -S --needed base-devel git paru
```

Current versions observed on this machine:

```text
base-devel 1-2
git 2.54.0-1.1
paru 2.1.0-2
```

### Core User Apps

Install the main user-facing native packages:

```bash
sudo pacman -S \
  kitty \
  firefox \
  neovim lazygit ripgrep starship \
  btop htop glances duf meld \
  pavucontrol piper \
  mpv haruna vlc-plugins-all spectacle obs-studio \
  steam proton-cachyos-slr
```

Current versions observed on this machine:

```text
kitty 0.46.2-1.2
firefox 150.0.1-1.1
neovim 0.12.2-1.1
lazygit 0.61.1-1.1
ripgrep 15.1.0-2
starship 1.25.1-1
btop 1.4.7-1.1
htop 3.5.1-1.1
glances 4.5.4-1
duf 0.9.1-1.1
meld 3.22.3-2
pavucontrol 1:6.2-1.1
piper 0.8-3
mpv 1:0.41.0-3.1
haruna 1.7.1-2.1
vlc-plugins-all 3.0.22-3.1
spectacle 1:6.6.4-1.1
obs-studio 32.1.2-2.1
steam 1.0.0.85-6
```

`proton-cachyos-slr` is installed for Steam/Overwatch. See the dedicated Overwatch section before changing its version.

### Terminal And Shell

Use Kitty as the terminal emulator and Bash as the interactive/login shell. Alacritty is intentionally not part of the fresh-install package list, but legacy Alacritty config may remain in dotfiles.

Install the relevant packages:

```bash
sudo pacman -S --needed bash kitty starship
```

Current shell/package state observed on this machine:

```text
login shell: /usr/bin/bash
bash 5.3.9-2
kitty 0.46.2-1.2
starship 1.25.1-1
```

Verify the login shell:

```bash
getent passwd "$USER"
```

Set Bash as the login shell if needed:

```bash
chsh -s /usr/bin/bash "$USER"
```

Relevant dotfiles:

```text
~/.bashrc
~/.bash_profile
~/.config/kitty/kitty.conf
```

Kitty explicitly starts Bash:

```text
shell /usr/bin/bash
```

Hyprland also uses Kitty as its terminal:

```text
$terminal = kitty
```

Fish is not part of the personal shell setup. If `fish` or `cachyos-fish-config` appears on a fresh CachyOS install, do not configure around it unless intentionally switching shells. The same applies to `zsh`/`cachyos-zsh-config` — these are CachyOS defaults and can be left installed but unused.

### Shell Integration Tools

The `.bashrc` configures integrations for these CLI tools:

- **starship** — prompt (installed via pacman, configured in `~/.config/starship.toml` with Catppuccin Mocha palette)
- **direnv** — per-directory environment loading (installed via `~/.local/bin` or cargo)
- **zoxide** — `cd` replacement with frecency ranking (installed via cargo)
- **fzf** — fuzzy finder with Catppuccin Mocha colors (installed from `~/.fzf`, cloned from upstream)
- **bat** — with `BAT_THEME="Catppuccin-mocha"`
- **ripgrep** — with `RIPGREP_CONFIG_PATH` pointing to `~/.config/ripgreprc`

Relevant `.bashrc` configuration for the above:

```bash
export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgreprc
export BAT_THEME="Catppuccin-mocha"
export FZF_DEFAULT_COMMAND="rg --files"
```

### Input And Keyboard

Install Fcitx5 from native packages and Kanata from AUR:

```bash
sudo pacman -S fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-chinese-addons
paru -S kanata
```

Current versions observed on this machine:

```text
fcitx5 5.1.19-1.1
fcitx5-chinese-addons 5.1.12-2.1
fcitx5-configtool 5.1.13-1.1
kanata 1.11.0-1
```

`kanata` is currently a foreign/AUR package on this machine:

```bash
pacman -Qm
```

Relevant setup is documented in the Fcitx5 and Kanata sections below.

### Communication Apps

Install QQ, Zoom, and 1Password from AUR:

```bash
paru -S linuxqq zoom 1password
```

Current foreign/AUR packages on this machine:

```text
kanata 1.11.0-1
linuxqq 5:3.2.28_48517-2
zoom 7.0.0-1
1password latest
```

### QQ With LiteLoader Plugins

QQ (Linux QQ) can be extended with LiteLoaderQQNT plugins for themes and Telegram-style message bubbles:

```bash
paru -S liteloader-qqnt-bin liteloader-qqnt-patcher
paru -S liteloader-qqnt-mspring-theme-bin liteloader-qqnt-telegram-theme-bin
```

Current versions observed on this machine:

```text
liteloader-qqnt-bin 1.4.0-1
liteloader-qqnt-patcher latest
liteloader-qqnt-mspring-theme-bin latest
liteloader-qqnt-telegram-theme-bin latest
```

### Optional Wayland/Hyprland Tools

KDE Plasma is the main desktop in these notes, but this machine also has Hyprland-related tooling and dotfiles:

```bash
sudo pacman -S hyprland wofi wl-clipboard uwsm xdg-desktop-portal-hyprland xsettingsd
```

Current versions observed on this machine:

```text
hyprland 0.54.3-4.1
wofi 1.5.3-1.1
wl-clipboard 1:2.3.0-1.1
uwsm 0.26.4-1
xdg-desktop-portal-hyprland 1.3.12-2.1
xsettingsd 1.0.2-3.1
```

### Fonts

Useful fonts currently installed for terminal, UI, emoji, and Chinese text:

```bash
sudo pacman -S \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd ttf-meslo-nerd \
  ttf-dejavu ttf-liberation ttf-opensans \
  awesome-terminal-fonts
```

### Cargo-Installed Tools

These CLI tools are installed via Cargo (not pacman) and used on this machine:

```bash
cargo install yazi-cli yazi-fm
cargo install zoxide
cargo install du-dust
```

Current versions:

```text
yazi 26.1.22
zoxide 0.9.9
du-dust 1.2.4
```

`yazi` is used as the terminal file manager (set as `$fileManager` in Hyprland config and accessible via Kitty `$terminal -e yazi`).

## Machine Specifications

This machine is a **Lenovo laptop** (unknown model number) used as a primary development and gaming workstation.

### Hardware

```text
CPU:    Intel Core i7-9750H @ 2.60GHz (6 cores, 12 threads)
GPU0:   Intel UHD Graphics 630 (integrated, CoffeeLake-H GT2)
GPU1:   NVIDIA GeForce GTX 1660 Ti Mobile (TU116M, 6GB VRAM)
RAM:    16 GB (15 Gi available)
NVMe:   SK Hynix HFS512GD9TNG-L3A0B (476.9 GB)
HDD:    Seagate ST1000LM049 (931.5 GB, 7200 RPM)
Audio:  Intel Cannon Lake PCH cAVS
```

### Operating System

```text
OS:             CachyOS
Kernel:         Linux 7.0.8-1-cachyos
Architecture:   x86-64
Hostname:       cachyos-x8664
```

## Storage And Boot Configuration

### Boot Loader

UEFI boot with **systemd-boot**. Secure Boot is disabled (setup mode).

```text
Firmware:       UEFI 2.60 (INSYDE Corp.)
Boot Loader:    systemd-boot 260.1-2-arch
```

### Kernel Command Line

```text
initrd=\initramfs-linux-cachyos.img
root=UUID=8844733d-9962-46b7-b17e-8c9c1df4f371
rw rootflags=subvol=/@
zswap.enabled=0 nowatchdog quiet splash
```

Notable: `zswap.enabled=0` disables zswap; `nowatchdog` disables NMI watchdog.

### Filesystem Layout

Btrfs on a single partition with subvolumes. The HDD is not configured in fstab.

```text
UUID=8844733d-9962-46b7-b17e-8c9c1df4f371 /          btrfs   subvol=/@,defaults,noatime,compress=zstd:1
UUID=8844733d-9962-46b7-b17e-8c9c1df4f371 /home      btrfs   subvol=/@home,defaults,noatime,compress=zstd:1
UUID=8844733d-9962-46b7-b17e-8c9c1df4f371 /root      btrfs   subvol=/@root,defaults,noatime,compress=zstd:1
UUID=8844733d-9962-46b7-b17e-8c9c1df4f371 /srv       btrfs   subvol=/@srv,defaults,noatime,compress=zstd:1
UUID=8844733d-9962-46b7-b17e-8c9c1df4f371 /var/cache btrfs   subvol=/@cache,defaults,noatime,compress=zstd:1
UUID=8844733d-9962-46b7-b17e-8c9c1df4f371 /var/tmp   btrfs   subvol=/@tmp,defaults,noatime,compress=zstd:1
UUID=8844733d-9962-46b7-b17e-8c9c1df4f371 /var/log   btrfs   subvol=/@log,defaults,noatime,compress=zstd:1
UUID=C706-3119                            /boot      vfat    defaults,umask=0077
tmpfs                                     /tmp       tmpfs   defaults,noatime,mode=1777
```

## NVIDIA PRIME Hybrid Graphics

This laptop uses **NVIDIA PRIME** for GPU offloading. The Intel GPU drives the display; the NVIDIA GPU is used on demand.

### Packages

```bash
sudo pacman -S nvidia-prime nvidia-settings switcheroo-control
```

Additional NVIDIA packages already present:

```text
nvidia-utils
lib32-nvidia-utils
libva-nvidia-driver
opencl-nvidia
lib32-opencl-nvidia
linux-cachyos-nvidia-open
```

### Usage

Launch applications on the NVIDIA GPU with:

```bash
prime-run <command>
```

## Input Method: Fcitx5 + Catppuccin

Use Fcitx5 for Chinese input. The Catppuccin theme is installed as a user theme and selected through the Classic User Interface addon.

### Packages

Install the core Fcitx5 packages, config UI, Chinese addons, and `git`:

```bash
sudo pacman -S fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-chinese-addons git
```

### Environment

For general desktop input, make sure these variables are available in the session environment:

```text
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
LC_CTYPE=zh_CN.UTF-8
```

Current file used on this machine:

```text
~/.config/environment.d/10-fcitx.conf
```

For Steam games that need Chinese input, per-game launch options can also include:

```bash
env LC_CTYPE=zh_CN.UTF-8 XMODIFIERS=@im=fcitx %command%
```

### Behavior Config

Edit:

```text
~/.config/fcitx5/config
```

Relevant values:

```ini
ActiveByDefault=False
ShareInputState=All
```

`ShareInputState=All` matters for Steam because Steam creates many `steamwebhelper` XIM input contexts. With `ShareInputState=No`, Steam can get stuck in `keyboard-us` even when Shuangpin works in other apps.

The default input method is set in:

```text
~/.config/fcitx5/profile
```

Relevant value:

```ini
DefaultIM=shuangpin
```

Reload Fcitx5 after changing this file:

```bash
fcitx5-remote -r
fcitx5-remote -o
fcitx5-remote -s shuangpin
```

Verify:

```bash
fcitx5-remote
fcitx5-remote -n
```

Expected:

```text
2
shuangpin
```

### Steam Shuangpin Troubleshooting

If Shuangpin does not work in Steam, check the Steam process environment:

```bash
pid="$(pgrep -n steam)"
tr '\0' '\n' < "/proc/$pid/environ" | rg '^(GTK_IM_MODULE|QT_IM_MODULE|SDL_IM_MODULE|XMODIFIERS|LC_CTYPE|LANG)='
```

Expected values include:

```text
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
SDL_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
LC_CTYPE=zh_CN.UTF-8
```

Observed problem state on this machine:

```text
Steam inherited GTK/QT/SDL/XMODIFIERS correctly, but did not have LC_CTYPE.
Fcitx was configured with ShareInputState=No.
The focused Steam XIM context existed, but the current IM was keyboard-us.
```

Fix applied:

```text
~/.config/environment.d/10-fcitx.conf includes LC_CTYPE=zh_CN.UTF-8
~/.config/fcitx5/config uses ShareInputState=All
Fcitx was reloaded and switched to shuangpin
```

Restart Steam after changing `~/.config/environment.d/10-fcitx.conf`; running Steam processes keep their old environment.

### Catppuccin Theme Install

Install the upstream Catppuccin Fcitx5 themes into the user theme directory:

```bash
tmp="$(mktemp -d)"
git clone --depth 1 https://github.com/catppuccin/fcitx5.git "$tmp"
mkdir -p ~/.local/share/fcitx5/themes
cp -r "$tmp/src/"* ~/.local/share/fcitx5/themes/
```

The theme names use this format:

```text
catppuccin-{flavour}-{accent}
```

Flavours:

```text
latte, frappe, macchiato, mocha
```

Accents:

```text
rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
```

Current preferred theme:

```text
catppuccin-mocha-mauve
```

### Fcitx5 Classic UI Config

Edit:

```text
~/.config/fcitx5/conf/classicui.conf
```

Relevant values:

```ini
Theme=catppuccin-mocha-mauve
DarkTheme=plasma
UseDarkTheme=False
UseAccentColor=True
```

Restart Fcitx5 after changing the theme:

```bash
fcitx5 -r
```

If `fcitx5 -r` starts Fcitx5 in the foreground or does not leave it running, start it as a daemon:

```bash
fcitx5 -d
```

Verify it is running:

```bash
pgrep -af fcitx5
```

### GUI Path

The same setting is available at:

```text
Fcitx 5 Configuration > Addons > Classic User Interface > Theme
```

If the popup appearance does not change on KDE Plasma, check whether KDE/Kimpanel is being used instead of the Classic UI theme. Kimpanel can make Fcitx5 follow Plasma styling rather than the selected Classic UI theme.

## Keyboard Remapping: Kanata

Kanata is used for one keyboard remap: Caps Lock is Escape when tapped and Left Control when held.

### Packages

Install Kanata from AUR with `paru`:

```bash
paru -S kanata
```

Current machine state:

```text
foreign/AUR package: kanata 1.11.0-1
packaged binary: /usr/bin/kanata, version 1.11.0
active binary via user service: ~/.cargo/bin/kanata, version 1.9.0
```

The user service prepends `~/.cargo/bin` to `PATH`, so `which kanata` resolves to the cargo-installed binary. For a clean install, prefer the packaged `/usr/bin/kanata` unless there is a specific reason to use the cargo binary.

### Remap Config

Active config file:

```text
~/.config/kanata/config.kbd
```

Current config:

```scheme
(defsrc
  caps
)

(defalias
  capsctrl (tap-hold 10 10 esc lctrl)
)

(deflayer base
  @capsctrl
)
```

Meaning:

- `defsrc` listens only to `caps`.
- `@capsctrl` applies the alias to Caps Lock in the base layer.
- `(tap-hold 10 10 esc lctrl)` makes Caps Lock send `esc` when tapped and `lctrl` when held, using `10` ms tap/hold timing values.

### Permissions

Kanata runs as the normal user, not root. The user must be able to read input devices and write to `/dev/uinput`.

Current user groups include:

```text
input
uinput
```

Set this up on a fresh install:

```bash
sudo groupadd -f uinput
sudo usermod -aG input,uinput "$USER"
```

Log out and back in after changing groups.

Current udev rule:

```text
/etc/udev/rules.d/99-input.rules
```

```udev
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
```

Create or refresh the rule on a fresh install:

```bash
printf '%s\n' 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-input.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

If `/dev/uinput` is missing, load the module:

```bash
sudo modprobe uinput
```

### User Systemd Service

The active setup is a user service, not the packaged system service.

Active service:

```text
~/.config/systemd/user/kanata.service
```

Current service:

```systemd
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Environment=PATH=%h/.cargo/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin
Type=simple
ExecStart=/usr/bin/sh -c 'exec $$(which kanata) --cfg $${HOME}/.config/kanata/config.kbd'
Restart=no

[Install]
WantedBy=default.target
```

Enable and start it:

```bash
systemctl --user daemon-reload
systemctl --user enable --now kanata.service
```

Check it:

```bash
systemctl --user status kanata.service
pgrep -af kanata
```

Current running process:

```text
~/.cargo/bin/kanata --cfg ~/.config/kanata/config.kbd
```

Current service state:

```text
systemctl --user is-enabled kanata.service -> enabled
systemctl --user is-active kanata.service -> active
loginctl show-user "$USER" -p Linger -> Linger=no
```

Because linger is disabled, this user service starts with the user session rather than running before login.

### Packaged System Service

The package also provides a system service, but it is disabled and inactive on this machine.

Packaged unit:

```text
/usr/lib/systemd/system/kanata.service
```

Current package unit:

```systemd
[Unit]
Description=kanata

[Service]
Restart=always
RestartSec=3
ExecStart=/usr/bin/kanata --cfg %E/kanata.kbd
Nice=-20

[Install]
WantedBy=default.target
```

Current state:

```text
systemctl is-enabled kanata.service -> disabled
systemctl show kanata.service -> inactive/dead
```

Do not enable both the user service and the system service at the same time for the same keyboard remap.

## Mouse: Logitech G502 With Piper

Use Piper/libratbag to configure the Logitech G502 mouse.

### Packages

Install Piper and libratbag:

```bash
sudo pacman -S piper libratbag
```

Current machine state:

```text
piper 0.8-3
libratbag 0.18-1
mouse USB ID: 046d:c07d (generic Logitech G502 USB ID, not device-unique)
libratbag device definition: /usr/share/libratbag/logitech-g502-proteus-core.device
ratbagctl name at time of setup: <device-name> (ratbag-generated local name; run `ratbagctl list` after reinstall)
```

Find the current ratbag device name:

```bash
ratbagctl list
```

Check the full mouse state:

```bash
ratbagctl <device-name> info
```

### Service

`ratbagd` is a D-Bus activated system service. It may show as disabled but still start when Piper or `ratbagctl` needs it.

```bash
systemctl status ratbagd.service --no-pager
systemctl is-enabled ratbagd.service
```

Current observed state:

```text
ratbagd.service: active/running
enabled state: disabled
```

The disabled state is not automatically a problem because D-Bus activation exists:

```text
/usr/share/dbus-1/system-services/org.freedesktop.ratbag1.service
```

### Profile Fix

Piper could detect the G502 and appeared to allow DPI/button changes, but the changes did not affect the mouse because the active profile was wrong.

Broken state observed:

```text
Profile 0: (disabled) (active)
Profile 1: (disabled)
Profile 2: configured but not active
active DPI: 2400dpi
```

The actual configured profile was profile 2. Set it active:

```bash
ratbagctl <device-name> profile active set 2
```

Verify:

```bash
ratbagctl <device-name> profile active get
ratbagctl <device-name> dpi get
```

Expected after the fix:

```text
active profile: 2
active DPI: 1800dpi
```

### Prevent Accidental Profile Switching

Button 8 was mapped to `profile-cycle-up`, which can switch away from the configured profile and make Piper changes look like they stopped working.

Disable that profile-cycle button on profile 2:

```bash
ratbagctl <device-name> profile 2 button 8 action set disabled
ratbagctl <device-name> profile active set 2
```

The second command matters because committing the button change can flip the active profile back to profile 0 on this mouse.

Verify:

```bash
ratbagctl <device-name> profile active get
ratbagctl <device-name> profile 2 button 8 action get
```

Expected:

```text
2
Button: 8 is mapped to none
```

### Current G502 Profile 2

Current configured profile:

```text
Profile 2: active
Report Rate: 1000Hz
DPI slots: 1400, 1800 active/default, 2200, 10000, 50 disabled
Button 0: button 1
Button 1: button 2
Button 2: button 3
Button 3: button 4
Button 4: macro KEY_LEFTCTRL
Button 5: resolution-alternate
Button 6: resolution-down
Button 7: resolution-up
Button 8: disabled
Button 9: wheel-right
Button 10: wheel-left
```

If Piper changes stop taking effect again, first check whether the active profile reverted:

```bash
ratbagctl <device-name> profile active get
ratbagctl <device-name> info
```

## Screen Recording: OBS Studio

Use OBS Studio when the recording must be exactly `1920x1080` regardless of KDE display scaling. Spectacle is good for quick clips, but its recording resolution follows the captured screen or region geometry from KDE/Wayland/PipeWire.

### Packages

Install OBS Studio:

```bash
sudo pacman -S obs-studio
```

Current machine state:

```text
pacman package: obs-studio 32.1.2-2.1
binary: /usr/bin/obs
runtime version: OBS Studio - 32.1.2
desktop entry: /usr/share/applications/com.obsproject.Studio.desktop
```

OBS uses the desktop portal/PipeWire path for KDE Wayland screen capture. The `obs-studio` package reported `xdg-desktop-portal-impl` as installed on this machine.

### 1080p Recording Setup

After first launch, set the video canvas and output size:

```text
Settings > Video
Base Canvas Resolution: 1920x1080
Output Scaled Resolution: 1920x1080
```

Recommended recording settings:

```text
Settings > Output > Recording
Recording Format: Matroska Video (.mkv)
```

Use `.mkv` while recording so a crash does not corrupt the whole file. If an `.mp4` is needed afterward, remux from OBS:

```text
File > Remux Recordings
```

For KDE Wayland capture, add one of these sources:

```text
Screen Capture (PipeWire)
Window Capture (PipeWire)
```

If the monitor is scaled or has a higher physical resolution, OBS can still produce a fixed `1920x1080` file because the output is controlled by the canvas/output resolution settings instead of Spectacle's direct capture geometry.

### KDE Wayland PipeWire Source Missing

If `Screen Capture (PipeWire)` or `Window Capture (PipeWire)` does not appear in OBS, first check that OBS is running under Wayland and that the PipeWire plugin exists:

```bash
printenv XDG_SESSION_TYPE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
ls /usr/lib/obs-plugins/linux-pipewire.so
```

Expected session values on this machine:

```text
XDG_SESSION_TYPE=wayland
WAYLAND_DISPLAY=wayland-0
XDG_CURRENT_DESKTOP=KDE
```

The issue seen on this machine was not a missing OBS plugin. OBS loaded `linux-pipewire.so`, but its log said:

```text
[pipewire] No capture sources available
```

The generic desktop portal incorrectly reported no available capture source types:

```bash
busctl --user --no-pager introspect org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.ScreenCast
```

Broken state:

```text
.AvailableSourceTypes property u 0 emits-change
```

The KDE backend itself was working and reported source types available:

```bash
busctl --user --no-pager introspect org.freedesktop.impl.portal.desktop.kde /org/freedesktop/portal/desktop org.freedesktop.impl.portal.ScreenCast
```

Working backend state:

```text
.AvailableSourceTypes property u 7 emits-change
```

Fix by restarting the user portal broker and KDE portal backend, then close and reopen OBS:

```bash
systemctl --user restart xdg-desktop-portal.service plasma-xdg-desktop-portal-kde.service
```

After the restart, the generic portal also reported:

```text
.AvailableSourceTypes property u 7 emits-change
```

Then OBS showed the PipeWire screen/window capture sources.

### Verification

Check the installed package and OBS version:

```bash
pacman -Q obs-studio
obs --version
```

## Gaming: Overwatch 144Hz on NVIDIA Hybrid Laptop

The key fix was using CachyOS Proton SLR 10.x for Overwatch, not Steam's Proton Experimental 11.x. Proton Experimental 11.x launched correctly but capped/dragged performance to about 40-50 FPS. Switching back to CachyOS Proton SLR 10.x restored 144Hz/144 FPS behavior.

### Working Proton Version

Install CachyOS Proton SLR 10.x:

```bash
SUDO_ASKPASS=/usr/bin/ksshaskpass sudo -A pacman -U --noconfirm 'https://archive.cachyos.org/archive/cachyos/proton-cachyos-slr-1:10.0.20260420-1-x86_64.pkg.tar.zst'
```

Working package:

```text
proton-cachyos-slr 1:10.0.20260420-1
```

The original known-good backup had:

```text
proton-cachyos-slr 1:10.0.20260408-1
```

The exact `20260408` package was not available later, but `20260420` fixed the issue and reports the same prefix generation:

```text
CachyOS-10.1000-200
```

Keep a local copy of the working package if possible, because CachyOS archive availability can change.

### Steam App ID

Overwatch Steam app ID:

```text
2357570
```

### Steam Launch Options

Use this launch option for Overwatch:

```bash
env LC_CTYPE=zh_CN.UTF-8 XMODIFIERS=@im=fcitx prime-run %command%
```

Notes:

- `prime-run` makes Overwatch use the NVIDIA GPU.
- `LC_CTYPE=zh_CN.UTF-8` and `XMODIFIERS=@im=fcitx` are for Chinese/Fcitx input support.
- Do not add `DXVK_ASYNC`, `DXVK_HUD`, or debug DXVK config unless actively diagnosing something.

### Steam Compatibility Mapping

File:

```text
~/.local/share/Steam/config/config.vdf
```

Relevant snippet:

```vdf
"CompatToolMapping"
{
    "2357570"
    {
        "name"      "proton-cachyos-slr"
        "config"    ""
        "priority"  "250"
    }
}
```

Steam UI equivalent:

```text
Overwatch > Properties > Compatibility > Force specific compatibility tool > proton-cachyos-10.0-20260420 (steam linux runtime)
```

The installed tool definition is:

```text
/usr/share/steam/compatibilitytools.d/proton-cachyos-slr/compatibilitytool.vdf
```

Expected display name:

```text
proton-cachyos-10.0-20260420 (steam linux runtime)
```

### Overwatch Video Config

File:

```text
~/.local/share/Steam/steamapps/compatdata/2357570/pfx/drive_c/users/steamuser/Documents/Overwatch/Settings/Settings_v0.ini
```

Relevant working values:

```ini
FullScreenRefresh = "144"
WindowedRefresh = "144"
VerticalSyncEnabled = "0"
UseCustomFrameRates = "0"
WindowMode = "0"
```

Meaning:

- `WindowMode = "0"` means fullscreen.
- `VerticalSyncEnabled = "0"` means V-Sync off.
- `FullScreenRefresh` and `WindowedRefresh` should both be `144`.
- `UseCustomFrameRates = "0"` was the working state. The game may rewrite this setting.

### Verification Commands

Check the Proton tool actually used after launching Overwatch:

```bash
pgrep -af 'proton-cachyos-slr|Overwatch.exe'
```

Expected path in process output:

```text
/usr/share/steam/compatibilitytools.d/proton-cachyos-slr/proton
```

Check the prefix version:

```bash
cat ~/.local/share/Steam/steamapps/compatdata/2357570/version
```

Expected output:

```text
CachyOS-10.1000-200
```

Check NVIDIA usage:

```bash
nvidia-smi
```

Expected:

```text
Overwatch.exe
```

Check display refresh:

```bash
kscreen-doctor -o
```

Expected internal display should show about `143.88` or `144` Hz.

### Things That Were Not Required

- Gamescope was not required.
- Plasma/KWin did not need to run on NVIDIA.
- Forcing KWin/Plasma to NVIDIA broke Wayland login on this laptop and should not be repeated.
- Plasma X11 did not fix the FPS problem by itself.
- NVIDIA was not globally capped; external NVIDIA OpenGL testing could reach thousands of FPS.
- The root cause was the Steam compatibility stack for Overwatch, specifically Proton Experimental 11.x versus CachyOS Proton SLR 10.x.

### Safe Reinstall Checklist

1. Install Steam and NVIDIA PRIME support.
2. Install or restore `proton-cachyos-slr` 10.x.
3. Set Overwatch compatibility tool to `proton-cachyos-slr`.
4. Set launch options to `env LC_CTYPE=zh_CN.UTF-8 XMODIFIERS=@im=fcitx prime-run %command%`.
5. Confirm `Settings_v0.ini` has 144Hz refresh and V-Sync off.
6. Launch Overwatch and verify the process path uses `proton-cachyos-slr`.
7. Test FPS in Practice Range, not menus.

## System Services

### Enabled System Services

Services enabled at the system level (beyond CachyOS defaults):

```text
bluetooth.service                # Bluetooth stack
switcheroo-control.service       # GPU switching for PRIME
```

Enable on a fresh install:

```bash
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now switcheroo-control.service
```

### Enabled User Services

```text
arch-update-tray.service    # CachyOS update systray applet (Cachy-Update)
kanata.service              # Keyboard remapper (Caps Lock → Esc/LCtrl)
wireplumber.service         # PipeWire session manager
xdg-user-dirs.service       # XDG user directory creation
```

The `arch-update-tray` service is provided by the `cachy-update` package and starts automatically in the graphical session. It shows a systray icon when updates are available.

### User Groups

Additional groups beyond the default:

```text
input    # Required by kanata to read input devices
uinput   # Required by kanata to write to /dev/uinput
```

## KDE Plasma Cursor Theme: Cat Cursors

Use the Cat Cursor theme from:

```text
https://github.com/Tseshongfeeshur/cat-cursors
```

This repo is an XDG cursor-theme port of the cat cursors. It was tested in KDE Plasma Wayland on this machine.

Current desktop/session context when configured:

```text
XDG_CURRENT_DESKTOP=KDE
DESKTOP_SESSION=/usr/share/wayland-sessions/plasma.desktop
XDG_SESSION_TYPE=wayland
```

### Required Packages

Install the tools needed to build and adjust the cursor theme:

```bash
SUDO_ASKPASS=/usr/bin/ksshaskpass sudo -A pacman -S --needed git imagemagick xorg-xcursorgen xcur2png
```

Notes:

- `magick` from ImageMagick is used by the upstream build script.
- `xcursorgen` is provided by `xorg-xcursorgen` and is required to build Xcursor files.
- `xcur2png` is useful for extracting and measuring Xcursor files when normalizing sizes.
- This machine has `ksshaskpass` at `/usr/bin/ksshaskpass`; use `SUDO_ASKPASS=/usr/bin/ksshaskpass sudo -A ...` for graphical sudo prompts.
- Do not store plaintext passwords in notes or chat.

### Install And Build Upstream Theme

The upstream README suggests installing the repo as `~/.local/share/icons/hei_cursors`, but the repo root itself does not contain `index.theme`. The actual XDG theme is generated from `sources/`.

Build in a temporary directory:

```bash
rm -rf /tmp/opencode/cat-cursors-normalize
git clone https://github.com/Tseshongfeeshur/cat-cursors.git /tmp/opencode/cat-cursors-normalize
cd /tmp/opencode/cat-cursors-normalize/sources
bash ./build.sh
```

The generated theme is:

```text
/tmp/opencode/cat-cursors-normalize/sources/cat_cursors
```

Install it for the current user:

```bash
tmpdir="$(mktemp -d /tmp/opencode/hei-cursors.XXXXXX)"
cp -a /tmp/opencode/cat-cursors-normalize/sources/cat_cursors/. "$tmpdir/"
rm -rf ~/.local/share/icons/hei_cursors
mv "$tmpdir" ~/.local/share/icons/hei_cursors
```

Theme metadata should exist at:

```text
~/.local/share/icons/hei_cursors/index.theme
```

Expected theme name:

```text
A Cat [hei_cursors]
```

Verify KDE sees it:

```bash
plasma-apply-cursortheme --list-themes
```

### Apply In KDE Plasma

Apply the theme:

```bash
plasma-apply-cursortheme hei_cursors
```

KDE may not update size with `plasma-apply-cursortheme --size` if the theme is already active. Write the config directly and reload the theme by briefly switching away and back:

```bash
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme hei_cursors
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 80
plasma-apply-cursortheme breeze_cursors
plasma-apply-cursortheme hei_cursors
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme hei_cursors
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 80
```

Current preferred cursor size:

```text
80
```

This was chosen after trying `100`, then making all cursors 20% smaller.

Verify current KDE cursor config:

```bash
kreadconfig6 --file kcminputrc --group Mouse --key cursorTheme
kreadconfig6 --file kcminputrc --group Mouse --key cursorSize
```

Expected:

```text
hei_cursors
80
```

### Why The Theme Mixes Cat And Breeze Cursors

The upstream `cat-cursors` repo only generates cat artwork for these cursor states:

```text
default
pointer
progress
size_ver
text
wait
```

The upstream build script copies fallback cursor files from `sources/breeze-cursors/`:

```bash
cp ./breeze-cursors/* "$OUT_XCUR_DIR"
```

Then it copies symlinks from `sources/links/`. Examples observed:

```text
hand1 -> pointer
hand2 -> pointer
pointing_hand -> pointer
grab -> openhand
grabbing -> closedhand
closedhand -> dnd-move
ns-resize -> size_ver
ew-resize -> size_hor
nwse-resize -> size_fdiag
nesw-resize -> size_bdiag
bottom_left_corner -> size_bdiag
bottom_right_corner -> size_fdiag
top_left_corner -> size_fdiag
top_right_corner -> size_bdiag
```

This means several hand/drag/resize states come from Breeze, not from cat artwork. Those copied Breeze files used different nominal sizing, which caused visible size mismatches.

### Normalize Cursor State Sizes

Problem observed:

```text
hand/openhand and resize cursor states appeared larger than the cat default/pointer states.
corner/diagonal resize looked larger than vertical/horizontal resize even when bounding boxes were similar.
```

The fix was to rebuild the generated cat states with a small scale adjustment and regenerate copied Breeze fallback cursor files with normalized visible bounds.

Patch `sources/build.sh` to add per-cursor scale factors:

```diff
+cursor_scale_factor() {
+    case "$1" in
+        size_ver) echo "0.87" ;;
+        progress) echo "0.93" ;;
+        *) echo "1" ;;
+    esac
+}
...
-        local scale=$(awk -v s="$SZ" -v o="$orig_size" 'BEGIN{printf "%.8f", s/o}')
+        local scale=$(awk -v s="$SZ" -v o="$orig_size" -v f="$cursor_factor" 'BEGIN{printf "%.8f", (s/o)*f}')
+        local image_size=$(awk -v s="$SZ" -v f="$cursor_factor" 'BEGIN{printf "%d", (s*f)+0.5}')
...
-                magick "$src_png" -resize "${SZ}x${SZ}" "$out_png"
+                magick "$src_png" -resize "${image_size}x${image_size}" "$out_png"
```

Full inserted logic around the original `orig_size` line:

```bash
cursor_scale_factor() {
    case "$1" in
        size_ver) echo "0.87" ;;
        progress) echo "0.93" ;;
        *) echo "1" ;;
    esac
}

# inside process_cursor, after orig_size is calculated:
local cursor_factor=$(cursor_scale_factor "$name")

# inside the SIZES loop:
local scale=$(awk -v s="$SZ" -v o="$orig_size" -v f="$cursor_factor" 'BEGIN{printf "%.8f", (s/o)*f}')
local image_size=$(awk -v s="$SZ" -v f="$cursor_factor" 'BEGIN{printf "%d", (s*f)+0.5}')

# resize with image_size instead of SZ:
magick "$src_png" -resize "${image_size}x${image_size}" "$out_png"
```

Add this helper as `sources/normalize_copied_cursors.sh`:

```bash
#!/bin/bash
set -euo pipefail

SIZES=(24 32 48 64 96 128 192 256)
OUT_XCUR_DIR="./cat_cursors/cursors"
TMP_DIR="./normalize_tmp"

cursor_target_ratio() {
    case "$1" in
        # Diagonal resize arrows look visually larger than their bounding box suggests.
        size_bdiag|size_fdiag) echo "0.36" ;;
        *) echo "0.50" ;;
    esac
}

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

normalize_cursor() {
    local name=$1
    local cursor_file="$OUT_XCUR_DIR/$name"
    local extract_dir="$TMP_DIR/$name/extract"
    local output_dir="$TMP_DIR/$name/output"
    local source_conf="$TMP_DIR/$name/source.conf"
    local output_conf="$TMP_DIR/$name/output.conf"

    if [ ! -f "$cursor_file" ]; then
        echo "[SKIP ] $name : cursor file not found"
        return
    fi

    mkdir -p "$extract_dir" "$output_dir"
    xcur2png -q -d "$extract_dir" -c "$source_conf" "$cursor_file" >/dev/null

    local source_size=0
    local source_xhot=0
    local source_yhot=0
    local source_path=""
    local source_delay=50

    while read -r size xhot yhot path delay; do
        case "$size" in
            ''|'#'*) continue ;;
        esac
        if [ "$size" -gt "$source_size" ]; then
            source_size=$size
            source_xhot=$xhot
            source_yhot=$yhot
            source_path=$path
            source_delay=$delay
        fi
    done < "$source_conf"

    local source_conf_dir=${source_conf%/*}
    case "$source_path" in
        /*) ;;
        *) source_path="$source_conf_dir/$source_path" ;;
    esac

    if [ -z "$source_path" ] || [ ! -f "$source_path" ]; then
        echo "[SKIP ] $name : extracted PNG not found"
        return
    fi

    local dimensions
    dimensions=$(magick "$source_path" -format '%wx%h' info:)
    local source_width=${dimensions%x*}
    local source_height=${dimensions#*x}
    local target_ratio
    target_ratio=$(cursor_target_ratio "$name")

    local trim_box trim_size trim_width trim_height trim_max
    trim_box=$(magick "$source_path" -alpha extract -format '%@' info:)
    trim_size=${trim_box%%+*}
    trim_width=${trim_size%x*}
    trim_height=${trim_size#*x}
    trim_max=$trim_width
    if [ "$trim_height" -gt "$trim_max" ]; then
        trim_max=$trim_height
    fi

    : > "$output_conf"

    for size in "${SIZES[@]}"; do
        local scale out_width out_height out_xhot out_yhot out_png
        scale=$(awk -v s="$size" -v r="$target_ratio" -v m="$trim_max" 'BEGIN{printf "%.8f", (s*r)/m}')
        out_width=$(awk -v v="$source_width" -v sc="$scale" 'BEGIN{n=(v*sc)+0.5; if (n < 1) n=1; printf "%d", n}')
        out_height=$(awk -v v="$source_height" -v sc="$scale" 'BEGIN{n=(v*sc)+0.5; if (n < 1) n=1; printf "%d", n}')
        out_xhot=$(awk -v v="$source_xhot" -v sc="$scale" 'BEGIN{printf "%d", (v*sc)+0.5}')
        out_yhot=$(awk -v v="$source_yhot" -v sc="$scale" 'BEGIN{printf "%d", (v*sc)+0.5}')
        out_png="$output_dir/${name}_${size}.png"

        magick "$source_path" -resize "${out_width}x${out_height}!" "$out_png"
        echo "$size $out_xhot $out_yhot $out_png $source_delay" >> "$output_conf"
    done

    xcursorgen "$output_conf" "$cursor_file"
    echo "Normalized: $name"
}

for cursor in openhand dnd-move all-scroll size_hor size_bdiag size_fdiag; do
    normalize_cursor "$cursor"
done

rm -rf "$TMP_DIR"
```

Rebuild and normalize:

```bash
cd /tmp/opencode/cat-cursors-normalize/sources
bash ./build.sh
bash ./normalize_copied_cursors.sh
```

Then reinstall the generated `cat_cursors` folder to `~/.local/share/icons/hei_cursors` and reload KDE as shown above.

### Verification Of Normalized Bounds

Use `xcur2png` and ImageMagick to inspect actual visible bounds. After normalization, measured at nominal size `96`:

```text
default 48x42
openhand 47x49
dnd-move 48x48
all-scroll 48x49
size_ver 45x48
size_hor 48x19
size_bdiag 34x34
size_fdiag 35x35
progress 47x48
```

The diagonal/corner resize cursors are intentionally smaller (`34x34` to `35x35`) because they look visually larger than their bounding box suggests. Corner aliases point to those diagonal resize files:

```text
nwse-resize -> size_fdiag
nesw-resize -> size_bdiag
bottom_left_corner -> size_bdiag
bottom_right_corner -> size_fdiag
top_left_corner -> size_fdiag
top_right_corner -> size_bdiag
```

### KDE Launch Feedback Bouncing Icon

KDE's bouncing application icon next to the cursor is not controlled by the cursor theme size. It is controlled by KDE launch feedback settings in `klaunchrc`.

Relevant KDE config schema:

```text
/usr/share/config.kcfg/launchfeedbacksettings.kcfg
```

Relevant groups and keys:

```text
[BusyCursorSettings]
Blinking=false
Bouncing=true
Timeout=5

[FeedbackStyle]
BusyCursor=true
TaskbarButton=true

[TaskbarButtonSettings]
Timeout=5
```

KDE exposes toggles for the bouncing icon, but no separate app-icon size setting was found. If the bouncing icon is too large, the practical configurable option is to disable bouncing rather than resizing it:

```bash
kwriteconfig6 --file klaunchrc --group BusyCursorSettings --key Bouncing false
```

To restore the default bouncing behavior:

```bash
kwriteconfig6 --file klaunchrc --group BusyCursorSettings --key Bouncing true
```

On this machine, the user chose to keep launch feedback unchanged.

### Persistent OpenCode Local Instruction

For future AI-agent sessions on this machine, global OpenCode instructions were added so the agent remembers that KDE askpass is available for sudo prompts.

Config file:

```text
~/.config/opencode/opencode.json
```

Current content:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["local-instructions.md"]
}
```

Instruction file:

```text
~/.config/opencode/local-instructions.md
```

Current content:

```markdown
# Local Machine Instructions

- This device has `ksshaskpass` at `/usr/bin/ksshaskpass` for sudo authentication prompts.
- When a command needs sudo authentication, prefer `SUDO_ASKPASS=/usr/bin/ksshaskpass sudo -A ...` so the user can approve the graphical prompt.
- Do not store plaintext passwords or ask the user to type passwords into chat.
```
