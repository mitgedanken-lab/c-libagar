package body agar.gui.window is

  use type c.int;

  function allocate_named
    (flags : flags_t := 0;
     name  : cs.chars_ptr) return window_access_t;
  pragma import (c, allocate_named, "AG_WindowNewNamed");

  function allocate_named
    (flags : flags_t := 0;
     name  : string) return window_access_t
  is
    ca_name : aliased c.char_array := c.to_c (name);
  begin
    return allocate_named
      (flags => flags,
       name  => cs.to_chars_ptr (ca_name'unchecked_access));
  end allocate_named;

  procedure set_caption
    (window  : window_access_t;
     fmt     : cs.chars_ptr;
     caption : cs.chars_ptr);
  pragma import (c, set_caption, "AG_WindowSetCaption");

  procedure set_caption
    (window  : window_access_t;
     caption : string)
  is
    ca_fmt     : aliased c.char_array := c.to_c ("%s");
    ca_caption : aliased c.char_array := c.to_c (caption);
  begin
    set_caption
      (window  => window,
       fmt     => cs.to_chars_ptr (ca_fmt'unchecked_access),
       caption => cs.to_chars_ptr (ca_caption'unchecked_access));
  end set_caption;

  procedure set_padding
    (window : window_access_t;
     left   : natural;
     right  : natural;
     top    : natural;
     bottom : natural) is
  begin
    set_padding
      (window => window,
       left   => c.int (left),
       right  => c.int (right),
       top    => c.int (top),
       bottom => c.int (bottom));
  end set_padding;

  procedure set_spacing
    (window  : window_access_t;
     spacing : natural) is
  begin
    set_spacing (window, c.int (spacing));
  end set_spacing;

  procedure set_position
    (window    : window_access_t;
     alignment : alignment_t;
     cascade   : boolean) is
  begin
    if cascade then
      set_position (window, alignment, 1);
    else
      set_position (window, alignment, 0);
    end if;
  end set_position;

  procedure set_geometry
    (window : window_access_t;
     x      : natural;
     y      : natural;
     width  : natural;
     height : natural) is
  begin
    set_geometry
      (window => window,
       x      => c.int (x),
       y      => c.int (y),
       width  => c.int (width),
       height => c.int (height));
  end set_geometry;

  procedure set_geometry_aligned
    (window    : window_access_t;
     alignment : alignment_t;
     width     : positive;
     height    : positive) is
  begin
    set_geometry_aligned
      (window    => window,
       alignment => alignment,
       width     => c.int (width),
       height    => c.int (height));
  end set_geometry_aligned;

  procedure set_geometry_aligned_percent
    (window    : window_access_t;
     alignment : alignment_t;
     width     : percent_t;
     height    : percent_t) is
  begin
    set_geometry_aligned_percent
      (window    => window,
       alignment => alignment,
       width     => c.int (width),
       height    => c.int (height));
  end set_geometry_aligned_percent;

  procedure set_geometry_bounded
    (window : window_access_t;
     x      : natural;
     y      : natural;
     width  : natural;
     height : natural) is
  begin
    set_geometry_bounded
      (window => window,
       x      => c.int (x),
       y      => c.int (y),
       width  => c.int (width),
       height => c.int (height));
  end set_geometry_bounded;

  function is_visible (window : window_access_t) return boolean is
  begin
    return is_visible (window) = 1;
  end is_visible;

  procedure set_visibility
    (window  : window_access_t;
     visible : boolean) is
  begin
    if visible then
      set_visibility (window, 1);
    else
      set_visibility (window, 0);
    end if;
  end set_visibility;

  function focus_named (name : string) return boolean is
    ca_name : aliased c.char_array := c.to_c (name);
  begin
    return focus_named (cs.to_chars_ptr (ca_name'unchecked_access)) = 0;
  end focus_named;

  function is_focused (window : window_access_t) return boolean is
  begin
    return is_focused (window) = 1;
  end is_focused;

end agar.gui.window;
