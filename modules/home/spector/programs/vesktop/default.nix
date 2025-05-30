{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.programs.vesktop;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.programs.vesktop = {
    enable = mkEnableOption "Enable Vesktop, a Discord client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ vesktop ];

    xdg.configFile = {
      "vesktop/themes/Catppuccin.theme.css".source = ./theme.css;

      # "vesktop/settings.json".text = builtins.toJSON {
      #   minimizeToTray = false;
      #   discordBranch = "canary";
      #   firstLaunch = false;
      #   arRPC = "on";
      #   splashColor = "rgb(219, 222, 225)";
      #   splashBackground = "rgb(49, 51, 56)";
      #   enableMenu = false;
      #   staticTitle = false;
      #   transparencyOption = ":)";
      # };
      #
      # "vesktop/settings/settings.json".text = builtins.toJSON {
      #   notifyAboutUpdates = false;
      #   autoUpdate = false;
      #   autoUpdateNotification = false;
      #   useQuickCss = true;
      #   themeLinks = [ ];
      #   enabledThemes = [ "Catppuccin.theme.css" ];
      #   enableReactDevtools = true;
      #   frameless = false;
      #   transparent = true;
      #   winCtrlQ = false;
      #   macosTranslucency = false;
      #   disableMinSize = false;
      #   winNativeTitleBar = false;
      #   plugins = {
      #     BadgeAPI.enabled = true;
      #     CommandsAPI.enabled = true;
      #     ContextMenuAPI.enabled = true;
      #     MemberListDecoratorsAPI.enabled = false;
      #     MessageAccessoriesAPI.enabled = false;
      #     MessageDecorationsAPI.enabled = false;
      #     MessageEventsAPI.enabled = true;
      #     MessagePopoverAPI.enabled = false;
      #     NoticesAPI.enabled = true;
      #     ServerListAPI.enabled = false;
      #     SettingsStoreAPI.enabled = false;
      #     "WebRichPresence (arRPC)".enabled = false;
      #     BANger.enabled = false;
      #     BetterFolders.enabled = false;
      #     BetterGifAltText.enabled = true;
      #     BetterNotesBox.enabled = false;
      #     BetterRoleDot.enabled = false;
      #     BetterUploadButton.enabled = false;
      #     BlurNSFW.enabled = false;
      #     CallTimer.enabled = false;
      #     ClearURLs.enabled = true;
      #     ColorSighted.enabled = false;
      #     ConsoleShortcuts.enabled = false;
      #     CrashHandler.enabled = true;
      #     CustomRPC.enabled = false;
      #     DisableDMCallIdle.enabled = false;
      #     EmoteCloner.enabled = false;
      #     Experiments.enabled = false;
      #     F8Break.enabled = false;
      #     FakeNitro.enabled = true;
      #     FakeProfileThemes.enabled = false;
      #     Fart2.enabled = false;
      #     FixInbox.enabled = false;
      #     ForceOwnerCrown.enabled = true;
      #     FriendInvites.enabled = false;
      #     FxTwitter.enabled = false;
      #     GameActivityToggle.enabled = true;
      #     GifPaste.enabled = false;
      #     HideAttachments.enabled = false;
      #     iLoveSpam.enabled = false;
      #     IgnoreActivities.enabled = false;
      #     ImageZoom.enabled = true;
      #     InvisibleChat.enabled = false;
      #     KeepCurrentChannel.enabled = false;
      #     LastFMRichPresence.enabled = false;
      #     LoadingQuotes.enabled = false;
      #     MemberCount.enabled = true;
      #     MessageClickActions.enabled = false;
      #     MessageLinkEmbeds.enabled = true;
      #     MessageLogger.enabled = true;
      #     MessageTags.enabled = false;
      #     MoreCommands.enabled = false;
      #     MoreKaomoji.enabled = false;
      #     MoreUserTags.enabled = false;
      #     Moyai.enabled = false;
      #     MuteNewGuild.enabled = false;
      #     NoBlockedMessages.enabled = false;
      #     NoCanaryMessageLinks.enabled = false;
      #     NoDevtoolsWarning.enabled = true;
      #     NormalizeMessageLinks.enabled = false;
      #     NoF1.enabled = true;
      #     NoReplyMention.enabled = false;
      #     NoScreensharePreview.enabled = false;
      #     NoTrack.enabled = true;
      #     NoUnblockToJump.enabled = false;
      #     NSFWGateBypass.enabled = true;
      #     oneko.enabled = false;
      #     petpet.enabled = false;
      #     PinDMs.enabled = false;
      #     PlainFolderIcon.enabled = false;
      #     PlatformIndicators.enabled = false;
      #     PronounDB.enabled = false;
      #     QuickMention.enabled = false;
      #     QuickReply.enabled = false;
      #     ReadAllNotificationsButton.enabled = false;
      #     RelationshipNotifier.enabled = true;
      #     RevealAllSpoilers.enabled = false;
      #     ReverseImageSearch.enabled = true;
      #     ReviewDB.enabled = false;
      #     RoleColorEverywhere.enabled = false;
      #     SearchReply.enabled = false;
      #     SendTimestamps.enabled = false;
      #     ServerListIndicators.enabled = false;
      #     Settings = {
      #       enabled = true;
      #       settingsLocation = "aboveActivity";
      #     };
      #     ShikiCodeblocks.enabled = false;
      #     ShowHiddenChannels.enabled = false;
      #     ShowMeYourName.enabled = false;
      #     SilentMessageToggle.enabled = false;
      #     SilentTyping.enabled = false;
      #     SortFriendRequests.enabled = false;
      #     SpotifyControls.enabled = false;
      #     SpotifyCrack.enabled = false;
      #     SpotifyShareCommands.enabled = false;
      #     StartupTimings.enabled = false;
      #     SupportHelper.enabled = true;
      #     TimeBarAllActivities.enabled = false;
      #     TypingIndicator.enabled = false;
      #     TypingTweaks.enabled = false;
      #     Unindent.enabled = true;
      #     ReactErrorDecoder.enabled = false;
      #     UrbanDictionary.enabled = false;
      #     UserVoiceShow.enabled = false;
      #     USRBG.enabled = false;
      #     UwUifier.enabled = false;
      #     VoiceChatDoubleClick.enabled = false;
      #     VcNarrator.enabled = false;
      #     ViewIcons.enabled = false;
      #     ViewRaw.enabled = false;
      #     WebContextMenus = {
      #       enabled = true;
      #       addBack = false;
      #     };
      #     WebKeybinds.enabled = true;
      #     GreetStickerPicker.enabled = false;
      #     WhoReacted.enabled = false;
      #     Wikisearch.enabled = false;
      #   };
      #   notifications = {
      #     timeout = 5000;
      #     position = "bottom-right";
      #     useNative = "not-focused";
      #     logLimit = 50;
      #   };
      #   cloud = {
      #     authenticated = false;
      #     url = "https://api.vencord.dev/";
      #     settingsSync = false;
      #     settingsSyncVersion = 1682768329526;
      #   };
      # };
    };
  };
}
