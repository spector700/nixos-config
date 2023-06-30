{ pkgs, ... }:

{
  programs = {
    kitty = {
      enable = true;
	font = {                          # Font - Laptop has size manually changed at home.nix
	  name = "JetBrainsMono Nerd Font";
	  #size = 8;
        };
      theme = "Tokyo Night";
      settings = {
	confirm_os_window_close = 0;	
      };
     };
    };
}
