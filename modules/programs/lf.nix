# lf file manager

{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    ctpv
  ];

  programs.lf = {
    enable = true;

    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
      scrolloff = 10;
      # Automatic refresh
      period = 1;
    };

    commands = {
      # dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
      open = ''
        &{{
            case $(file --mime-type -Lb $f) in
                text/*) lf -remote "send $id \$$EDITOR \$fx";;
                *) for f in $fx; do $OPENER $f > /dev/null 2> /dev/null & done;;
            esac
        }}
      '';

      mkdir = ''
        ''${{
            printf "Directory Name: "
            read DIR
            mkdir $DIR
          }}
      '';

      on-select = ''
        &{{
            lf -remote "send $id set statfmt \"$(exa -ld --color=always "$f")\""
        }}
      '';

      fzf_jump = ''
          ''${{
            res="$(find . | ${pkgs.fzf}/bin/fzf --preview 'bat --color=always {}' --border --header='Jump to location')"
            if [ -n "$res" ]; then
                if [ -d "$res" ]; then
                    cmd="cd"
                else
                    cmd="select"
                fi
                res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
                lf -remote "send $id $cmd \"$res\""
            fi
        }}
      '';

      fzf_search = ''
        ''${{
        RG_PREFIX="${pkgs.ripgrep}/bin/rg --column --line-number --no-heading --color=always --smart-case "
        res="$(
            FZF_DEFAULT_COMMAND="$RG_PREFIX ''''" \
                ${pkgs.fzf}/bin/fzf --bind "change:reload:$RG_PREFIX {q} || true" \
                --ansi --layout=reverse --header 'Search in files' \
                | cut -d':' -f1 | sed 's/\\/\\\\/g;s/"/\\"/g'
        )"
        [ -n "$res" ] && lf -remote "send $id select \"$res\""
        }}
      '';

      extract = ''
          ''${{
            set -f
            case $f in
                *.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar xjvf $f;;
                *.tar.gz|*.tgz) tar xzvf $f;;
                *.tar.xz|*.txz) tar xJvf $f;;
                *.zip) unzip $f;;
                *.rar) unrar x $f;;
                *.7z) 7z x $f;;
            esac
        }}
      '';

      trash = ''%${pkgs.trash-cli}/bin/trash-put $fx'';

      trash-restore = ''
          ''${{
            ids="$(echo -ne '\n' | \
              ${pkgs.trash-cli}/bin/trash-restore | \
              awk '$1 ~ /^[0-9]+/ {print $0}' | \
              ${pkgs.fzf}/bin/fzf --multi --reverse | \
              awk '{print $1}' | \
              sed -z 's/\n/,/g;s/,$/\n/')"
            echo $ids | ${pkgs.trash-cli}/bin/trash-restore 
            clear
        }}
      '';
    };

    keybindings = {

      # Disable 
      d = "";

      "/" = "fzf_jump";
      a = "mkdir";
      "." = "set hidden!";
      "`" = "mark-load";
      "<enter>" = "open";
      x = "cut";
      dd = "trash";
      U = "trash-restore";

      # goto
      gs = "fzf_search";
      gh = "cd";
      gd = "cd ~/Downloads";
      gD = "cd ~/Documents";
      gc = "cd ~/.config";

    };

    extraConfig =
      ''
        set previewer ctpv
        set cleaner ctpvclear
        &ctpv -s $id
        &ctpvquit $id
      '';
  };

  xdg.configFile."lf/icons".text = ''
    # These examples require Nerd Fonts or a compatible font to be used.
    # See https://www.nerdfonts.com for more information.

    # default values from lf (with matching order)
    # ln      l       # LINK
    # or      l       # ORPHAN
    # tw      t       # STICKY_OTHER_WRITABLE
    # ow      d       # OTHER_WRITABLE
    # st      t       # STICKY
    # di      d       # DIR
    # pi      p       # FIFO
    # so      s       # SOCK
    # bd      b       # BLK
    # cd      c       # CHR
    # su      u       # SETUID
    # sg      g       # SETGID
    # ex      x       # EXEC
    # fi      -       # FILE

    # file types (with matching order)
    ln             # LINK
    or             # ORPHAN
    tw      t       # STICKY_OTHER_WRITABLE
    ow             # OTHER_WRITABLE
    st      t       # STICKY
    di             # DIR
    pi      p       # FIFO
    so      s       # SOCK
    bd      b       # BLK
    cd      c       # CHR
    su      u       # SETUID
    sg      g       # SETGID
    ex             # EXEC
    fi             # FILE

    # file extensions (vim-devicons)
    *.styl          
    *.sass          
    *.scss          
    *.htm           
    *.html          
    *.slim          
    *.haml          
    *.ejs           
    *.css           
    *.less          
    *.md            
    *.mdx           
    *.markdown      
    *.rmd           
    *.json          
    *.webmanifest   
    *.js            
    *.mjs           
    *.jsx           
    *.rb            
    *.gemspec       
    *.rake          
    *.php           
    *.py            
    *.pyc           
    *.pyo           
    *.pyd           
    *.coffee        
    *.mustache      
    *.hbs           
    *.conf          
    *.ini           
    *.yml           
    *.yaml          
    *.toml          
    *.bat           
    *.mk            
    *.jpg           
    *.jpeg          
    *.bmp           
    *.png           
    *.webp          
    *.gif           
    *.ico           
    *.twig          
    *.cpp           
    *.c++           
    *.cxx           
    *.cc            
    *.cp            
    *.c             
    *.cs            󰌛
    *.h             
    *.hh            
    *.hpp           
    *.hxx           
    *.hs            
    *.lhs           
    *.nix           
    *.lua           
    *.java          
    *.sh            
    *.fish          
    *.bash          
    *.zsh           
    *.ksh           
    *.csh           
    *.awk           
    *.ps1           
    *.ml            λ
    *.mli           λ
    *.diff          
    *.db            
    *.sql           
    *.dump          
    *.clj           
    *.cljc          
    *.cljs          
    *.edn           
    *.scala         
    *.go            
    *.dart          
    *.xul           
    *.sln           
    *.suo           
    *.pl            
    *.pm            
    *.t             
    *.rss           
    '*.f#'          
    *.fsscript      
    *.fsx           
    *.fs            
    *.fsi           
    *.rs            
    *.rlib          
    *.d             
    *.erl           
    *.hrl           
    *.ex            
    *.exs           
    *.eex           
    *.leex          
    *.heex          
    *.vim           
    *.ai            
    *.psd           
    *.psb           
    *.ts            
    *.tsx           
    *.jl            
    *.pp            
    *.vue           
    *.elm           
    *.swift         
    *.xcplayground  
    *.tex           󰙩
    *.r             󰟔
    *.rproj         󰗆
    *.sol           󰡪
    *.pem           

    # file names (vim-devicons) (case-insensitive not supported in lf)
    *gruntfile.coffee       
    *gruntfile.js           
    *gruntfile.ls           
    *gulpfile.coffee        
    *gulpfile.js            
    *gulpfile.ls            
    *mix.lock               
    *dropbox                
    *.ds_store              
    *.gitconfig             
    *.gitignore             
    *.gitattributes         
    *.gitlab-ci.yml         
    *.bashrc                
    *.zshrc                 
    *.zshenv                
    *.zprofile              
    *.vimrc                 
    *.gvimrc                
    *_vimrc                 
    *_gvimrc                
    *.bashprofile           
    *favicon.ico            
    *license                
    *node_modules           
    *react.jsx              
    *procfile               
    *dockerfile             
    *docker-compose.yml     
    *rakefile               
    *config.ru              
    *gemfile                
    *makefile               
    *cmakelists.txt         
    *robots.txt             󰚩

    # file names (case-sensitive adaptations)
    *Gruntfile.coffee       
    *Gruntfile.js           
    *Gruntfile.ls           
    *Gulpfile.coffee        
    *Gulpfile.js            
    *Gulpfile.ls            
    *Dropbox                
    *.DS_Store              
    *LICENSE                
    *React.jsx              
    *Procfile               
    *Dockerfile             
    *Docker-compose.yml     
    *Rakefile               
    *Gemfile                
    *Makefile               
    *CMakeLists.txt         

    # file patterns (vim-devicons) (patterns not supported in lf)
    # .*jquery.*\.js$         
    # .*angular.*\.js$        
    # .*backbone.*\.js$       
    # .*require.*\.js$        
    # .*materialize.*\.js$    
    # .*materialize.*\.css$   
    # .*mootools.*\.js$       
    # .*vimrc.*               
    # Vagrantfile$            

    # file patterns (file name adaptations)
    *jquery.min.js          
    *angular.min.js         
    *backbone.min.js        
    *require.min.js         
    *materialize.min.js     
    *materialize.min.css    
    *mootools.min.js        
    *vimrc                  
    Vagrantfile             

    # archives or compressed (extensions from dircolors defaults)
    *.tar   
    *.tgz   
    *.arc   
    *.arj   
    *.taz   
    *.lha   
    *.lz4   
    *.lzh   
    *.lzma  
    *.tlz   
    *.txz   
    *.tzo   
    *.t7z   
    *.zip   
    *.z     
    *.dz    
    *.gz    
    *.lrz   
    *.lz    
    *.lzo   
    *.xz    
    *.zst   
    *.tzst  
    *.bz2   
    *.bz    
    *.tbz   
    *.tbz2  
    *.tz    
    *.deb   
    *.rpm   
    *.jar   
    *.war   
    *.ear   
    *.sar   
    *.rar   
    *.alz   
    *.ace   
    *.zoo   
    *.cpio  
    *.7z    
    *.rz    
    *.cab   
    *.wim   
    *.swm   
    *.dwm   
    *.esd   

    # image formats (extensions from dircolors defaults)
    *.jpg   
    *.jpeg  
    *.mjpg  
    *.mjpeg 
    *.gif   
    *.bmp   
    *.pbm   
    *.pgm   
    *.ppm   
    *.tga   
    *.xbm   
    *.xpm   
    *.tif   
    *.tiff  
    *.png   
    *.svg   
    *.svgz  
    *.mng   
    *.pcx   
    *.mov   
    *.mpg   
    *.mpeg  
    *.m2v   
    *.mkv   
    *.webm  
    *.ogm   
    *.mp4   
    *.m4v   
    *.mp4v  
    *.vob   
    *.qt    
    *.nuv   
    *.wmv   
    *.asf   
    *.rm    
    *.rmvb  
    *.flc   
    *.avi   
    *.fli   
    *.flv   
    *.gl    
    *.dl    
    *.xcf   
    *.xwd   
    *.yuv   
    *.cgm   
    *.emf   
    *.ogv   
    *.ogx   

    # audio formats (extensions from dircolors defaults)
    *.aac   
    *.au    
    *.flac  
    *.m4a   
    *.mid   
    *.midi  
    *.mka   
    *.mp3   
    *.mpc   
    *.ogg   
    *.ra    
    *.wav   
    *.oga   
    *.opus  
    *.spx   
    *.xspf  

    # other formats
    *.pdf   
  '';

  xdg.configFile."lf/colors".text = ''
     # file types (with matching order)
    ln      01;36   # LINK
    or      31;01   # ORPHAN
    tw      34      # STICKY_OTHER_WRITABLE
    ow      34      # OTHER_WRITABLE
    st      01;34   # STICKY
    di      01;34   # DIR
    pi      33      # FIFO
    so      01;35   # SOCK
    bd      33;01   # BLK
    cd      33;01   # CHR
    su      37;41   # SETUID
    sg      01;32   # SETGID
    ex      01;32   # EXEC
    fi      00      # FILE

    # archives or compressed (dircolors defaults)
    *.tar   01;31
    *.tgz   01;31
    *.arc   01;31
    *.arj   01;31
    *.taz   01;31
    *.lha   01;31
    *.lz4   01;31
    *.lzh   01;31
    *.lzma  01;31
    *.tlz   01;31
    *.txz   01;31
    *.tzo   01;31
    *.t7z   01;31
    ##*.zip   01;38;5;61
    *.zip   01;31
    *.z     01;31
    *.dz    01;31
    *.gz    01;31
    *.lrz   01;31
    *.lz    01;31
    *.lzo   01;31
    *.xz    01;31
    *.zst   01;31
    *.tzst  01;31
    *.bz2   01;31
    *.bz    01;31
    *.tbz   01;31
    *.tbz2  01;31
    *.tz    01;31
    *.deb   01;31
    *.rpm   01;31
    *.jar   01;31
    *.war   01;31
    *.ear   01;31
    *.sar   01;31
    *.rar   01;31
    *.alz   01;31
    *.ace   01;31
    *.zoo   01;31
    *.cpio  01;31
    *.7z    01;31
    *.rz    01;31
    *.cab   01;31
    *.wim   01;31
    *.swm   01;31
    *.dwm   01;31
    *.esd   01;31

    # image formats (dircolors defaults)
    *.jpg   00;33
    *.jpeg  00;33
    *.mjpg  00;33
    *.mjpeg 00;33
    *.webp  00;33
    *.gif   00;33
    *.bmp   00;33
    *.pbm   00;33
    *.pgm   00;33
    *.ppm   00;33
    *.tga   00;33
    *.xbm   00;33
    *.xpm   00;33
    *.tif   00;33
    *.tiff  00;33
    *.png   00;38;5;215
    *.svg   00;33
    *.svgz  00;33
    *.mng   00;33
    *.pcx   00;33
    *.mov   00;35
    *.mpg   00;35
    *.mpeg  00;35
    *.m2v   00;33
    *.mkv   00;33
    *.webm  00;35
    *.ogm   00;33
    *.mp4   00;35
    *.m4v   00;35
    *.mp4v  00;35
    *.vob   00;35
    *.qt    00;33
    *.nuv   00;33
    *.wmv   00;35
    *.asf   00;33
    *.rm    00;33
    *.rmvb  00;33
    *.flc   00;33
    *.avi   00;35
    *.fli   00;33
    *.flv   00;35
    *.gl    00;33
    *.dl    00;33
    *.xcf   00;33
    *.xwd   00;33
    *.yuv   00;33
    *.cgm   00;33
    *.emf   00;33
    *.ogv   00;33
    *.ogx   00;33

    # audio formats (dircolors defaults)
    *.aac   00;36
    *.au    00;36
    *.flac  00;36
    *.m4a   00;36
    *.mid   00;36
    *.midi  00;36
    *.mka   00;36
    *.mp3   00;36
    *.mpc   00;36
    *.ogg   00;36
    *.ra    00;36
    *.wav   00;36
    *.oga   00;36
    *.opus  00;36
    *.spx   00;36
    *.xspf  00;36   
  '';

}
