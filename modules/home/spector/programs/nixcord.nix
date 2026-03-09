{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.programs.nixcord;
  inherit (lib) mkIf mkEnableOption;
in
{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  options.modules.programs.nixcord = {
    enable = mkEnableOption "Enable nixcord";
  };

  config = mkIf cfg.enable {
    programs.nixcord = {
      enable = true;

      discord = {
        enable = false;
        vencord.enable = false;
      };

      vesktop = {
        enable = true;
        settings = {
          # discordBranch = "stable";
          arRPC = "on";
          # splashColor = "#${config.lib.stylix.colors.base05}";
          # splashBackground = "#${config.lib.stylix.colors.base00}";
          # splashTheming = true;
          # checkUpdates = false;
          # disableMinSize = true;
          tray = true;
          hardwareAcceleration = true;
          firstLaunch = false;
        };
      };

      config = {
        plugins = {
          # === UI / UX ===
          alwaysTrust.enable = true;
          betterFolders.enable = true;
          betterRoleContext.enable = true;
          crashHandler.enable = true;
          experiments.enable = true;
          fakeNitro.enable = true;
          fixSpotifyEmbeds.enable = true;
          imageZoom.enable = true;
          memberCount.enable = true;
          permissionsViewer.enable = true;
          PinDMs.enable = true;
          quickMention.enable = true;
          readAllNotificationsButton.enable = true;
          revealAllSpoilers.enable = true;
          serverListIndicators.enable = true;
          showHiddenChannels.enable = true;
          spotifyControls.enable = true;
          themeAttributes.enable = true;
          typingIndicator.enable = true;
          voiceMessages.enable = true;
          volumeBooster.enable = true;
          webContextMenus.enable = true;
          whoReacted.enable = true;

          # === Privacy ===
          anonymiseFileNames.enable = true;
          ClearURLs.enable = true;

          # === Logging / Notifications ===
          messageLogger.enable = true;
          relationshipNotifier.enable = true;
        };

        useQuickCss = true;
        frameless = true;
      };
    };
  };
}
