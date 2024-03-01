{ inputs, config, pkgs, lib, ... }:
{

  imports = [
    inputs.self.homeManagerModules.theme
    inputs.matugen.nixosModules.default
  ];

  # light/dark specialisations
  specialisation =
    let
      colorschemePath = "/org/gnome/desktop/interface/color-scheme";
      dconf = "${pkgs.dconf}/bin/dconf";

      dconfDark = lib.hm.dag.entryAfter [ "dconfSettings" ] ''
        ${dconf} write ${colorschemePath} "'prefer-dark'"
      '';
      dconfLight = lib.hm.dag.entryAfter [ "dconfSettings" ] ''
        ${dconf} write ${colorschemePath} "'prefer-light'"
      '';
    in
    {
      light.configuration = {
        theme.name = "light";
        home.activation = { inherit dconfLight; };
      };
      dark.configuration = {
        theme.name = "dark";
        home.activation = { inherit dconfDark; };
      };
    };

  programs.matugen = {
    enable = false;
    inherit (config.theme) wallpaper;
  };
}
