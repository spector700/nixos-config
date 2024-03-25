{ pkgs, config, lib, ... }:
let
  inherit (lib) optionals;
in
{

  users.users.${config.modules.system.mainUser} = {
    # System User
    isNormalUser = true;
    extraGroups = [ "wheel" ] ++ optionals config.networking.networkmanager.enable [ "networkmanager" ];
    initialPassword = "changeme";
    shell = pkgs.zsh; # Default shell
  };

}
