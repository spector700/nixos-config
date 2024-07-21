{
  inputs,
  location,
  lib,
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
        "nix-command"
        "flakes"
      ];
      flake-registry = "/etc/nix/registry.json";
      warn-dirty = false;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://fufexan.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      ];
    };

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: { flake = v; }) inputs;

    # add your inputs to the system's legacy channels
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "electron-25.9.0" ];
  };

  # By default nix-gc makes no effort to respect battery life by avoding
  # GC runs on battery and fully commits a few cores to collecting garbage.
  # This will drain the battery faster than you can say "Nix, what the hell?"
  # and contribute heavily to you wanting to get a new desktop.
  # For those curious (such as myself) desktops are always seen as "AC powered"
  # so the system will not fail to fire if you are on a desktop system.
  systemd.services.nix-gc = {
    unitConfig.ConditionACPower = true;
  };

  system.stateVersion = "23.05";
}
