#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix *
#   └─ ./modules
#       └─ ./shell
#           └─ default.nix
#

{ config, lib, pkgs, inputs, user, ... }:

{
   imports =
    (import ../modules/shell);  

  users.users.${user} = {                   # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;                       # Default shell
  };
  security.sudo.wheelNeedsPassword = false; # User does not need to give password when using sudo.

  time.timeZone = "America/Chicago";        # Time zone and internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {                 # Extra locale settings that need to be overwritten
      LC_TIME = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
    };
  };

  systemd.extraConfig = ''
     DefaultTimeoutStopSec=10s
   '';

  console = {
    font = "JetBrainsMono Nerd Font";
    keyMap = "us";
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  fonts.fonts = with pkgs; [                # Fonts
    font-awesome
       (nerdfonts.override { fonts = [ "FiraCode" "Hack" "JetBrainsMono" ]; })
  ];

  environment = {
    variables = {
      TERMINAL = "kitty";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [           # Default packages installed system-wide
      wget
      neofetch
      xdg-utils
    ];
  };

  services = {
    printing = {                                # Printing and drivers for TS5300
      enable = true;
      #drivers = [ pkgs.cnijfilter2 ];          # There is the possibility cups will complain about missing cmdtocanonij3. I guess this is just an error that can be ignored for now. Also no longer need required since server uses ipp to share printer over network.
    };
    avahi = {                                   # Needed to find wireless printer
      enable = true;
      nssmdns = true;
      publish = {                               # Needed for detecting the scanner
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
    pipewire = {                            # Sound
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {                             # SSH: secure shell (remote connection to shell of server)
      enable = true;                        # local: $ ssh <user>@<ip>
                                            # public:
                                            #   - port forward 22 TCP to server
                                            #   - in case you want to use the domain name insted of the ip:
                                            #       - for me, via cloudflare, create an A record with name "ssh" to the correct ip without proxy
                                            #   - connect via ssh <user>@<ip or ssh.domain>
                                            # generating a key:
                                            #   - $ ssh-keygen   |  ssh-copy-id <ip/domain>  |  ssh-add
                                            #   - if ssh-add does not work: $ eval `ssh-agent -s`
      allowSFTP = true;                     # SFTP: secure file transfer protocol (send file to server)
                                            # connect: $ sftp <user>@<ip/domain>
                                            #   or with file browser: sftp://<ip address>
                                            # commands:
                                            #   - lpwd & pwd = print (local) parent working directory
                                            #   - put/get <filename> = send or receive file
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';                                   # Temporary extra config so ssh will work in guacamole
    };
    flatpak.enable = true;                  # download flatpak file from website - sudo flatpak install <path> - reboot if not showing up
                                            # sudo flatpak uninstall --delete-data <app-id> (> flatpak list --app) - flatpak uninstall --unused
                                            # List:
                                            # com.obsproject.Studio
                                            # com.parsecgaming.parsec
                                            # com.usebottles.bottles
  };

  nix = {                                   # Nix Package Manager settings
    settings ={
      auto-optimise-store = true;           # Optimise syslinks
    };
    gc = {                                  # Automatic garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.unstable;    # Enable nixFlakes on system
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.allowUnfree = true;        # Allow proprietary software.

  system = {                                # NixOS settings
    autoUpgrade = {                         # Allow auto update (not useful in flakes)
      enable = true;
    };
    stateVersion = "23.05";
  };
}
