#
# Neovim
#


{ pkgs, config, location, ... }:

{

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${location}/modules/editors/neovim/nvim";

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    # withPython3 = true;

  };
  home.packages = with pkgs; [
    # LSP
    nodePackages_latest.typescript-language-server
    nodePackages_latest."@tailwindcss/language-server"
    nodePackages_latest.bash-language-server
    nodePackages_latest.pyright
    sumneko-lua-language-server
    nixd
    ruff-lsp

    # Format
    nixpkgs-fmt
    stylua
    beautysh
    nodePackages.prettier
    black

    gcc
    # cargo
    ripgrep
    fd
    lazygit
  ];
}
