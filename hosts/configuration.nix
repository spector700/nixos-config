#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix *
#   └─ ./modules
#       └─ ./shell
#           └─ default.nix
#

{ config, lib, pkgs, inputs, user, system, ... }:

{
  # configuration used by all hosts

  users.users.${user} = {
    # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh; # Default shell
  };
  security.sudo.wheelNeedsPassword = false; # User does not need to give password when using sudo.

  time.timeZone = "America/Chicago"; # Time zone and internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      # Extra locale settings that need to be overwritten
      LC_TIME = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];

  # Boot logo
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    # Boot logo
    plymouth = {
      enable = true;
    };
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting = {
        enable = true;
        patterns = { "rm -rf *" = "fg=black,bg=red"; };
        styles = { "alias" = "fg=blue"; };
        highlighters = [ "main" "brackets" "pattern" ];
      };
    };
  };

  # remove bloat
  documentation.nixos.enable = false;

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  console = {
    font = "ter-v20n";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  systemd = {
    user.services.polkit-kde-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  programs.partition-manager.enable = true;

  fonts.packages = with pkgs; [
    # Fonts
    font-awesome
    noto-fonts-cjk-sans
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  environment = {
    variables = {
      TERMINAL = "kitty";
      EDITOR = "nvim";
      VISUAL = "nvim";
      # Variable for nh
      FLAKE = "/home/${user}/.config/nixos-config";
    };
    systemPackages = [
      inputs.nh.packages.${pkgs.system}.default
    ];
  };

  services = {
    printing = {
      # Go to the CUPS settings and add: socket://HPC85ACF1BB858.local 
      enable = true;
      drivers = with pkgs; [ hplip ];
      browsedConf = ''
        BrowseDNSSDSubTypes _cups,_print
        BrowseLocalProtocols all
        BrowseRemoteProtocols all
        CreateIPPPrinterQueues All

        BrowseProtocols all
      '';
    };
    avahi = {
      # Needed to find wireless printer
      enable = true;
      openFirewall = true;
      nssmdns = true;
      publish = {
        # Needed for detecting the scanner
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
    pipewire = {
      # Sound
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    openssh = {
      enable = true; # local: $ ssh <user>@<ip>
      # public:
      #   - port forward 22 TCP to server
      #   - in case you want to use the domain name insted of the ip:
      #       - for me, via cloudflare, create an A record with name "ssh" to the correct ip without proxy
      #   - connect via ssh <user>@<ip or ssh.domain>
      # generating a key:
      #   - $ ssh-keygen   |  ssh-copy-id <ip/domain>  |  ssh-add
      #   - if ssh-add does not work: $ eval `ssh-agent -s`
      allowSFTP = true; # SFTP: secure file transfer protocol (send file to server)
      # connect: $ sftp <user>@<ip/domain>
      #   or with file browser: sftp://<ip address>
      # commands:
      #   - lpwd & pwd = print (local) parent working directory
      #   - put/get <filename> = send or receive file
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      ''; # Temporary extra config so ssh will work in guacamole
    };
    flatpak.enable = true;
  };

  nh = {
    enable = true;
    clean.enable = true;
  };

  nix = {
    # Nix Package Manager settings
    settings = {
      auto-optimise-store = true; # Optimise syslinks
    };
    # gc = {
    #   # Automatic garbage collection
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 7d";
    # };
    package = pkgs.nixVersions.unstable; # Enable nixFlakes on system
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      builders-use-substitutes = true;
      substituters = [
        "https://nix-gaming.cachix.org"
        "https://anyrun.cachix.org"
      ];

      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true; # Allow proprietary software.


  system = {
    stateVersion = "23.05";
  };
}
