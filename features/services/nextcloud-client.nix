_: {
  flake.aspects.nextcloud-client.homeManager.services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
