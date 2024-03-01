{ inputs, user, ... }:
{
  imports = [
    inputs.anyrun.homeManagerModules.default
    inputs.spicetify.homeManagerModules.default
    inputs.dev-assistant.homeManagerModules.default
    inputs.hyprlock.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default
    ./colorscheme.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "23.05";
  };

  programs.home-manager.enable = true;
}
