{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    inputs.spicetify.homeManagerModules.default
    ./desktops
    ./programs
    ./roles
    ./services
    ./shell
    ./theming
    ./editors
  ];

  home = {
    username = "spector";
    homeDirectory = "/home/${config.home.username}";
    # <https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion>
    # this is and should remain the version on which you have initiated your config
    stateVersion = "23.05";
  };

  manual = {
    # save space
    html.enable = false;
    json.enable = false;
    manpages.enable = true;
  };

  programs.home-manager.enable = true;

  # reload system units when changing configs
  systemd.user.startServices = mkDefault "sd-switch";
}
