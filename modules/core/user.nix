{ pkgs, config, lib, ... }:
let
  inherit (lib) optionals;
  user = config.modules.system.mainUser;
in
{
  users.users.${user} = {
    # System User
    isNormalUser = true;
    extraGroups = [ "wheel" ] ++ optionals config.networking.networkmanager.enable [ "networkmanager" ];
    initialPassword = "changeme";
    shell = pkgs.zsh; # Default shell
  };
}
