{ inputs, location, lib, config, ... }: {
  environment.variables.FLAKE = "${location}";

  imports = [ inputs.nh.nixosModules.default ];

  nh = {
    enable = true;
    # weekly clean
    clean = {
      enable = true;
      extraArgs = "--keep-since 30d";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "/etc/nix/registry.json";
      warn-dirty = false;

      substituters =
        [ "https://nix-community.cachix.org" "https://fufexan.cachix.org" ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      ];
    };

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: { flake = v; }) inputs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];

  system.stateVersion = "23.05";
}
