{
  programs.yazi.theme.manager = {
    cwd = {
      fg = "#94e2d5";
    };

    # Hovered
    hovered = {
      fg = "#1e1e2e";
      bg = "#89b4fa";
    };

    preview_hovered = {
      underline = true;
    };

    # Find
    find_keyword = {
      fg = "#f9e2af";
      italic = true;
    };
    find_position = {
      fg = "#f5c2e7";
      bg = "reset";
      italic = true;
    };

    # Marker
    marker_copied = {
      fg = "#a6e3a1";
      bg = "#a6e3a1";
    };
    marker_cut = {
      fg = "#f38ba8";
      bg = "#f38ba8";
    };
    marker_selected = {
      fg = "#89b4fa";
      bg = "#89b4fa";
    };

    # Tab
    tab_active = {
      fg = "#1e1e2e";
      bg = "#cdd6f4";
    };
    tab_inactive = {
      fg = "#cdd6f4";
      bg = "#45475a";
    };
    tab_width = 1;

    # Count
    count_copied = {
      fg = "#1e1e2e";
      bg = "#a6e3a1";
    };
    count_cut = {
      fg = "#1e1e2e";
      bg = "#f38ba8";
    };
    count_selected = {
      fg = "#1e1e2e";
      bg = "#89b4fa";
    };

    # Border;
    border_symbol = "│";
    border_style = {
      fg = "#7f849c";
    };

    # Offset;
    folder_offset = [
      1
      0
      1
      0
    ];
    preview_offset = [
      1
      1
      1
      1
    ];

    # Highlighting;
    syntect_theme = "";
  };
}
