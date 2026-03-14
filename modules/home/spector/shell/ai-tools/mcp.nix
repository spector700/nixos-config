{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
in
{
  programs.mcp = {
    enable = true;
    servers = {
      # filesystem = {
      #   args = mkDefault [
      #     config.home.homeDirectory
      #     "${config.home.homeDirectory}/Documents"
      #   ];
      # };

      nixos = {
        command = getExe pkgs.mcp-nixos;
      };

      exa = {
        url = "https://mcp.exa.ai/mcp";
      };

      deepwiki = {
        url = "https://mcp.deepwiki.com/mcp";
      };

      playwright = {
        command = getExe pkgs.playwright-mcp;
        args = [ "--viewport-size" "1280x720" ];
        env = {
          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
          PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
        };
      };
    };
  };
}
