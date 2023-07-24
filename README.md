<p align="center"><img src="https://i.imgur.com/X5zKxvp.png" width=300px></p>

<p align="center">
  <a href="https://hyprland.org/">
    <img src="https://img.shields.io/static/v1?label=Hyprland&message=latest&style=flat&logo=hyprland&colorA=24273A&colorB=8AADF4&logoColor=CAD3F5"/>
  </a>
   <a href="https://github.com/zemmsoares/awesome-rices">
    <img src="https://raw.githubusercontent.com/zemmsoares/awesome-rices/main/assets/awesome-rice-badge.svg" alt="awesome-rice-badge">
  </a>
  <a href="https://nixos.wiki/wiki/Flakes">
    <img src="https://img.shields.io/static/v1?label=Nix Flake&message=check&style=flat&logo=nixos&colorA=24273A&colorB=9173ff&logoColor=CAD3F5">
  </a>
</p>

* Table of Content
:PROPERTIES:
:TOC:      :include all :depth 2 :force (depth) :ignore (this)
:END:
:CONTENTS:
- [[#system-components][System Components]]
- [[#nixos-installation-guide][NixOS Installation Guide]]
- [[#nix-installation-guide][Nix Installation Guide]]
:END:

* System Components
|                 | *NixOS -Wayland* | *NixOS - Wayland/Xorg* | *NixOS - Xorg*   |
|-----------------+------------------+------------------------+------------------|
| *DM*            | greetd           | GDM                    | LightDM          |
| *WM/DE*         | Hyprland         | Gnome                  | Bspwm            |
| *Compositor*    | Hyprland         | Mutter                 | Picom (jonaburg) |
| *Bar*           | Waybar           | Dock-to-Panel          | Polybar          |
| *Hotkeys*       | Hyprland         | /                      | Sxhkd            |
| *Launcher*      | Wofi             | Gnome                  | Rofi             |
| *GTK Theme*     | Dracula          | Dracula / Adwaita      | Dracula          |
| *Notifications* | Dunst            | Gnome                  | Dunst            |
| *Terminal*      | Kitty            | Alacritty              | Alacritty        |
| *Used by host*  | Desktop          | Work                   | Laptop & VM      |

There are some other desktop environments/window manager (See NixOS - Other). Just link to correct ~default/home.nix~ in ~./hosts/<host>/default and home.nix~.
There is also a general Nix config with hostname ~pacman~ that can be used on pretty much any disto.

Compontents relevant to all hosts:
| *Shell*    | Zsh               |
| *Terminal* | Kitty             |
| *Editors*  | Nvim              |

* NixOS Installation Guide
This flake currently has *1* hosts
 1. desktop
    - UEFI boot w/ systemd-boot
 2. laptop
    - UEFI boot w/ grub (Dual Boot)

Flakes can be build with:
- ~$ sudo nixos-rebuild switch --flake <path>#<hostname>~
- example ~$ sudo nixos-rebuild switch --flake .#desktop~

** Installation
*** UEFI
*In these commands*
- Mount partition with label ... on ...
  - "nixos" -> ~/mnt~
  - "boot" -> ~/mnt/boot~
#+begin_src
  # mount /dev/disk/by-label/nixos /mnt
  # mkdir -p /mnt/boot
  # mount /dev/disk/by-label/boot /mnt/boot
#+end_src

*** Mounting Extras
*In these commands*
  - ~/mnt/ssd~
- Label of storage:
  - ssd2
- If storage has no label:
  - ~mount /dev/disk/by-uuid/ssd2 /mnt/ssd~
#+begin_src
  # mkdir -p /mnt/ssd
  # mount /dev/disk/by-label/ssd2 /mnt/ssd
#+end_src

*** Generate
*In these commands*
- Swap is enable:
  - Ignore if no swap or enough RAM
- Configuration files are generated @ ~/mnt/etc/nixos~
  - If you are me, you don't need to do this. Hardware-configuration.nix already in flake.
- Clone repository
#+begin_src
  # nixos-generate-config --root /mnt
  # nix-shell -p git
  # git clone https://github.com/spector700/nixos-config /mnt/etc/nixos/<name>

  Optional for new hardware
  # cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nixos-config/hosts/<host>/.
#+end_src

*** Possible Extra Steps
1. Switch specific host hardware-configuration.nix with generated ~/mnt/etc/nixos/hardware-configuration.nix~
2. Change existing network card name with the one in your system
   - Look in generated hardware-configuration.nix
   - Or enter ~$ ip a~
3. Change username in flake.nix

*** Install
*In these commands*
- Move into cloned repository
  - in this example ~/mnt/etc/nixos/<name>~
- Available hosts:
  - desktop
  - laptop
#+begin_src
  # cd /mnt/etc/nixos/<name>
  # nixos-install --flake .#<host>
#+end_src

** Finalization
1. Set a root password after installation is done
2. Reboot without liveCD
3. Login
   1. If initialPassword is not set use TTY:
      - ~Ctrl - Alt - F1~
      - login as root
      - ~# passwd <user>~
      - ~Ctrl - Alt - F7~
      - login as user
4. Optional:
   - ~$ sudo mv <location of cloned directory> <prefered location>~
   - ~$ sudo chown -R <user>:users <new directory location>~
   - ~$ sudo rm /etc/nixos/configuration.nix~ - This is done because in the past it would auto update this config if you would have auto update in your configuration.
   - or just clone flake again do apply same changes.
5. Dual boot:
   - OSProber probably did not find your Windows partition after the first install
   - There is a high likelihood it will find it after:
     - ~$ sudo nixos-rebuild switch --flake <config path>#<host>~
6. Rebuilds:
   - ~$ sudo nixos-rebuild switch --flake <config path>#<host>~
   - For example ~$ sudo nixos-rebuild switch --flake ~/.setup#matthias~

* Nix Installation Guide
This flake currently has *1* host
  1. pacman

The Linux distribution must have the nix package manager installed.
~$ sh <(curl -L https://nixos.org/nix/install) --daemon~

** Installation
*** Initial
*In these commands*
- Get git
- Clone repository
- First build of the flake
  - This is done so we can use the home-manager command is part of PATH.

#+begin_src
  $ nix-shell -p git
  $ git clone https://github.com/spector700/nixos-config ~/.setup
  $ cd ~/.setup
  $ nix build --extra-experimental-features 'nix-command flakes' .#homeConfigurations.<host>.activationPackage
  $ ./result/activate
#+end_src

*** Rebuild
Since home-manager is now a valid command we can rebuild the system using this command. In this example it is build from inside the flake directory:
- ~$ home-manager switch --flake <config path>#<host>~
This will rebuild the configuration and automatically activate it.

** Finalization
*Mostly optional or already correct by default*
1. NixGL gets set up by default, so if you are planning on using GUI applications that use OpenGL or Vulkan:
   - ~$ nixGLIntel <package>~
   - or add it to your aliases file
2. Every rebuild, and activation-script will run to add applications to the system menu.
   - it's pretty much the same as adding the path to XDG_DATA_DIRS
   - if you do not want to or if the locations are different, change this.
