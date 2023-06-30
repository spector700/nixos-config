#
# Neovim
#

{ pkgs, ... }:

{
  programs = {
    neovim = {
      enable = true;

      configure = {
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
        packages.myVimPackages = with pkgs.vimPlugins; {
          start = [
            LazyVim
           ];
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    lazygit
  ];      
}
