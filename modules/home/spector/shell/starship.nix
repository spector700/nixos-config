{ lib, ... }:
{
  programs = {
    starship = {
      enable = true;
      settings = {
        format = lib.concatStrings [
          "[](#3B4252)"
          "[](bg:#434C5E fg:#3B4252)"
          "$directory"
          "[](fg:#434C5E bg:#4C566A)"
          "$git_branch"
          "$git_status"
          "[](fg:#4C566A bg:#86BBD8)"
          "$python"
          "$c"
          "$elixir"
          "$golang"
          "$java"
          "$nodejs"
          "$rust"
          "[](fg:#86BBD8 bg:#06969A)"
          "$docker_context"
          "[](fg:#06969A bg:#33658A)"
          "$time"
          "[ ](fg:#33658A)"
        ];

        # Disable the blank line at the start of the prompt
        # add_newline = false

        directory = {
          style = "bg:#434C5E";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        # Here is how you can shorten some long paths by text replacement
        # similar to mapped_locations in Oh My Posh:
        directory.substitutions = {
          "Documents" = " ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };
        # Keep in mind that the order matters. For example:
        # "Important Documents" = "  "
        # will not be replaced, because "Documents" was already substituted before.
        # So either put "Important Documents" before "Documents" or use the substituted version:
        # "Important  " = "  "

        python = {
          format = "[$symbol(($virtualenv) )]($style)";
          style = "bg:#86BBD8";
          symbol = "";
        };

        c = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };

        docker_context = {
          symbol = " ";
          style = "bg:#06969A";
          format = "[ $symbol $context ]($style) $path";
        };

        elixir = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };

        git_branch = {
          symbol = "";
          style = "bg:#4C566A";
          format = "[ $symbol $branch (:$remote_branch)]($style)";
        };

        git_status = {
          style = "bg:#4C566A";
          format = "[$all_status$ahead_behind ]($style)";
        };

        golang = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };

        java = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
      };
    };
  };
}
