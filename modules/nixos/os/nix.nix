{
  inputs,
  location,
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.nh = {
    enable = true;
    flake = "${location}";
    # weekly clean
    clean = {
      enable = true;
      dates = "weekly";
    };
  };

  # faster rebuilding
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [
        # enables flakes, needed for this config
        "flakes"

        # enables the nix3 commands, a requirement for flakes
        "nix-command"
      ];
      # flake-registry = "/etc/nix/registry.json";

      # we don't want to track the registry, but we do want to allow the usage
      # of the `flake:` references, so we need to enable use-registries
      use-registries = true;
      flake-registry = pkgs.writers.writeJSON "flakes-empty.json" {
        flakes = [ ];
        version = 2;
      };

      # let the system decide the number of max jobs
      max-jobs = "auto";

      # continue building derivations even if one fails
      keep-going = true;

      # show more log lines for failed builds
      log-lines = 30;

      warn-dirty = false;

      # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
      http-connections = 50;

      trusted-users = [
        "root"
        "@wheel"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://fufexan.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://pre-commit-hooks.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      ];
    };

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: { flake = v; }) inputs;

    # add your inputs to the system's legacy channels
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;
  };

  nixpkgs.config = {
    allowUnfree = true;

    # But occasionally we need to install some anyway so we can predicated those
    # these are usually packages like electron
    permittedInsecurePackages = [ ];
  };

  # By default nix-gc makes no effort to respect battery life by avoiding
  # GC runs on battery and fully commits a few cores to collecting garbage.
  # This will drain the battery faster than you can say "Nix, what the hell?"
  # and contribute heavily to you wanting to get a new desktop.
  # For those curious (such as myself) desktops are always seen as "AC powered"
  # so the system will not fail to fire if you are on a desktop system.
  systemd.services.nix-gc = {
    unitConfig.ConditionACPower = true;
  };

  # this is the NixOS version that the configuration was generated with
  # this should be change to the version of the NixOS release that the configuration was generated with
  system.stateVersion = "23.05";
}
