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
#       ├─ ./editors
  };
  environment.systemPackages = with pkgs; [
    ripgrep
    cargo
    fd
    lazygit
    gcc
  ];
}
