#
# Neovim
#


{ pkgs, config, ... }:

{

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/modules/editors/neovim/nvim";

  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = true;

  };

  home.packages = with pkgs; [
    gcc
    ripgrep
    fd
    lazygit
    tree-sitter

    # LSP
    nodePackages.vscode-langservers-extracted
    nodePackages_latest.typescript
    nodePackages_latest.typescript-language-server
    nodePackages_latest.bash-language-server
    sumneko-lua-language-server
    nixd

    # Format
    nixpkgs-fmt
    stylua
    beautysh
    nodePackages.prettier
  ];


}
