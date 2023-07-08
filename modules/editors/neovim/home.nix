#
# Neovim
#

{ pkgs, ... }:

{
  programs = {
    neovim = {
      enable = true;
      withNodeJs = true;
      withRuby = true;
      withPython3 = true;
      extraPython3Packages = pyPkgs: with pyPkgs; [ pip ];

      # configure = {
       # customRC = ''
       #   syntax enable
       #   colorscheme srcery

       #   let g:lightline = {
       #     \ 'colorscheme': 'wombat',
       #     \ }

       #   highlight Comment cterm=italic gui=italic
       #   hi Normal guibg=NONE ctermbg=NONE

       #   set number

       #   nmap <F6> :NERDTreeToggle<CR>
       # '';
      #   packages.myVimPackages = with pkgs.vimPlugins; {
      #     start = [
      #      ];
      #   };
      # };
    };
  };
  home.packages = with pkgs; [
    ripgrep
    cargo
    fd
    lazygit
    gcc
  ];
}
