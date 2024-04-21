------------------------------------------------------------------------------
--                             AGAR GUI LIBRARY                             --
--                          A G A R  . W I D G E T                          --
--                                 B o d y                                  --
--                                                                          --
-- Copyright (c) 2018-2024 Julien Nadeau Carriere (vedge@csoft.net)         --
--                                                                          --
-- Permission to use, copy, modify, and/or distribute this software for any --
-- purpose with or without fee is hereby granted, provided that the above   --
-- copyright notice and this permission notice appear in all copies.        --
--                                                                          --
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES --
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF         --
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR  --
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES   --
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN    --
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF  --
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.           --
------------------------------------------------------------------------------
package body Agar.Widget is
  --
  -- Return the first visible widget intersecting a point or enclosing a
  -- rectangle (in view coordinates). Scan all drivers and return first match.
  --
  --function Find_At_Point
  --  (Class : in String;
  --   X,Y   : in Natural) return Widget_Access;
  --function Find_Enclosing_Rect
  --  (Class : in String;
  --   X,Y   : in Natural;
  --   W,H   : in Positive) return Widget_Access;

  --
  -- Set whether to accept (or deny) focused state.
  --
  procedure Set_Focusable
    (Widget : in Widget_not_null_Access;
     Enable : in Boolean)
  is
    Former_Status : aliased C.int;
  begin
    if Enable then
      Former_Status := AG_WidgetSetFocusable (Widget, C.int(1));
    else
      Former_Status := AG_WidgetSetFocusable (Widget, C.int(0));
    end if;
  end;

  --
  -- Set whether to accept (or deny) focused state (return previous).
  --
  function Set_Focusable
    (Widget : in Widget_not_null_Access;
     Enable : in Boolean) return Boolean
  is
  begin
    if Enable then
      return 1 = AG_WidgetSetFocusable (Widget, C.int(1));
    else
      return 1 = AG_WidgetSetFocusable (Widget, C.int(0));
    end if;
  end;

  --
  -- Focus on the widget (and implicitely its parents up to and including
  -- the parent window).
  --
  function Focus
    (Widget : in Widget_not_null_Access) return Boolean is
  begin
    return 0 = AG_WidgetFocus (Widget);
  end;
  
  --
  -- Return the topmost visible widget intersecting a display-coordinate point.
  --
  function Find_Widget_At_Point
    (Class : String;
     X,Y   : Natural) return Widget_Access
  is
    Ch_Class : aliased C.char_array := C.To_C(Class);
  begin
    return AG_WidgetFindPoint
        (Class => CS.To_Chars_Ptr(Ch_Class'Unchecked_Access),
         X     => C.int(X),
         Y     => C.int(Y));
  end;

  --
  -- Return topmost visible widget intersecting a display-coordinate rectangle.
  --
  function Find_Widget_Enclosing_Rect
    (Class : String;
     X,Y   : Natural;
     W,H   : Positive) return Widget_Access
  is
    Ch_Class : aliased C.char_array := C.To_C(Class);
  begin
    return AG_WidgetFindRect
      (Class  => CS.To_Chars_Ptr(Ch_Class'Unchecked_Access),
       X      => C.int(X),
       Y      => C.int(Y),
       W      => C.int(W),
       H      => C.int(H));
  end;
  
  --
  -- Update the cached absolute display (rView) coordinates of a widget, and
  -- of its descendants. The Widget and its parent VFS must both be locked.
  --
  procedure Update_Coordinates
    (Widget : in Widget_not_null_Access;
     X      : in Natural;
     Y      : in Natural) is
  begin
    AG_WidgetUpdateCoords
      (Widget => Widget,
       X      => C.int(X),
       Y      => C.int(Y));
  end;
  
  --
  -- Free any Surface mapped to the given handle (as returned by Map_Surface).
  -- Delete any hardware texture associated with the surface.
  --
  procedure Unmap_Surface
    (Widget : in Widget_not_null_Access;
     Handle : in Surface_Handle) is
  begin
    Replace_Surface
      (Widget  => Widget,
       Handle  => Handle,
       Surface => null);
  end;
  
  --
  -- Blit the surface (or render the hardware texture) at Source:[Handle],
  -- at target coordinates X,Y relative to Widget.
  --
  -- Source may be different from Widget (i.e., Widgets may render other
  -- widgets' surfaces) as long as both widgets are in the same Window.
  --
  procedure Blit_Surface
    (Widget   : in Widget_not_null_Access;
     Source   : in Widget_not_null_Access;
     Handle   : in Surface_Handle;
     Src_Rect : in SU.Rect_Access := null;
     X,Y      : in Natural := 0) is
  begin
    AG_WidgetBlitFrom
      (Widget   => Widget,
       Source   => Source,
       Handle   => Handle,
       Src_Rect => Src_Rect,
       X        => C.int(X),
       Y        => C.int(Y));
  end;
  
  --
  -- Blit the surface (or render the hardware texture) at Widget:[Handle],
  -- at target coordinates X,Y relative to Widget.
  --
  procedure Blit_Surface
    (Widget   : in Widget_not_null_Access;
     Handle   : in Surface_Handle;
     Src_Rect : in SU.Rect_Access := null;
     X,Y      : in Natural := 0) is
  begin
    AG_WidgetBlitFrom
      (Widget   => Widget,
       Source   => Widget,
       Handle   => Handle,
       Src_Rect => Src_Rect,
       X        => C.int(X),
       Y        => C.int(Y));
  end;
  
  --
  -- Blit a Surface not managed by the Widget. This method is inefficient
  -- (no hardware acceleration) and should be avoided.
  --
  procedure Blit_Surface
    (Widget   : in Widget_not_null_Access;
     Surface  : in SU.Surface_not_null_Access;
     X,Y      : in Natural := 0) is
  begin
    AG_WidgetBlit
      (Widget   => Widget,
       Surface  => Surface,
       X        => C.int(X),
       Y        => C.int(Y));
  end;
  
  --
  -- Test whether widget is sensitive to view coordinates X,Y.
  --
  function Is_Sensitive
    (Widget : in Widget_not_null_Access;
     X,Y    : in Natural) return Boolean is
  begin
    return 1 = AG_WidgetSensitive
      (Widget => Widget,
       X      => C.int(X),
       Y      => C.int(Y));
  end;

  --
  -- Change the cursor if its coordinates overlap a registered cursor area.
  -- Generally called from window/driver code following a mouse motion event.
  --
  procedure Mouse_Cursor_Update
    (Window : in Window_not_null_Access;
     X,Y    : in Natural) is
  begin
    AG_MouseCursorUpdate
      (Window => Window,
       X      => C.int(X),
       Y      => C.int(Y));
  end;

  --
  -- Handle a mouse motion. Called from Driver code (agDrivers must be locked).
  --
  procedure Process_Mouse_Motion
    (Window      : in Window_not_null_Access;
     X,Y         : in Natural;
     X_Rel,Y_Rel : in Integer;
     Buttons     : in Mouse_Button) is
  begin
    AG_ProcessMouseMotion
      (Window  => Window,
       X       => C.int(X),
       Y       => C.int(Y),
       X_Rel   => C.int(X_Rel),
       Y_Rel   => C.int(Y_Rel),
       Buttons => Buttons);
  end;

  --
  -- Handle a mouse button release.
  -- Called from Driver code (agDrivers must be locked).
  --
  procedure Process_Mouse_Button_Up
    (Window    : in Window_not_null_Access;
     X,Y       : in Natural;
     Button    : in Mouse_Button) is
  begin
    AG_ProcessMouseButtonUp
      (Window => Window,
       X      => C.int(X),
       Y      => C.int(Y),
       Button => Button);
  end;

  --
  -- Handle a mouse button press.
  -- Called from Driver code (agDrivers must be locked).
  --
  procedure Process_Mouse_Button_Down
    (Window    : in Window_not_null_Access;
     X,Y       : in Natural;
     Button    : in Mouse_Button) is
  begin
    AG_ProcessMouseButtonDown
      (Window => Window,
       X      => C.int(X),
       Y      => C.int(Y),
       Button => Button);
  end;

  ------------------
  -- Keyboard API --
  ------------------

  --
  -- Create a new keyboard instance under a Driver.
  --
  function New_Keyboard
    (Driver : in Agar.Widget.Driver_not_null_Access;
     Descr  : in String) return Keyboard_not_null_Access
  is
    Ch_Descr : aliased C.char_array := C.To_C(Descr);
  begin
    return AG_KeyboardNew
      (Driver => Driver,
       Descr  => CS.To_Chars_Ptr(Ch_Descr'Unchecked_Access));
  end;

  ---------------
  -- Mouse API --
  ---------------

  --
  -- Create a new mouse instance under a Driver.
  --
  function New_Mouse
    (Driver : in Driver_not_null_Access;
     Descr  : in String) return Mouse_not_null_Access
  is
    Ch_Descr : aliased C.char_array := C.To_C(Descr);
  begin
    return AG_MouseNew
      (Driver => Driver,
       Descr  => CS.To_Chars_Ptr(Ch_Descr'Unchecked_Access));
  end;

  ----------------
  -- Window API --
  ----------------

  --
  -- Create a new Agar window.
  --
  function New_Window
    (Caption         : in String := "";
     Name            : in String := "";
     Driver          : in Driver_Access := null;
     W,H             : in Natural := 0;
     Min_W,Min_H     : in Natural := 0;
     Alignment       : in Window_Alignment := MIDDLE_CENTER;
     Modal           : in Boolean := False;
     Maximized       : in Boolean := False;
     Minimized       : in Boolean := False;
     Keep_Above      : in Boolean := False;
     Keep_Below      : in Boolean := False;
     Deny_Focus      : in Boolean := False;
     Titlebar        : in Boolean := True;
     Borders         : in Boolean := True;
     H_Resize        : in Boolean := True;
     V_Resize        : in Boolean := True;
     Close_Button    : in Boolean := True;
     Minimize_Button : in Boolean := True;
     Maximize_Button : in Boolean := True;
     Tileable        : in Boolean := False;
     BG_Fill         : in Boolean := True;
     Main            : in Boolean := False;
     H_Maximize      : in Boolean := False;
     V_Maximize      : in Boolean := False;
     Movable         : in Boolean := True;
     Inherit_Zoom    : in Boolean := False;
     Fade_In         : in Boolean := False;
     Fade_Out        : in Boolean := False) return Window_not_null_Access
  is
    C_Flags    : C.unsigned := 0;
    Ch_Name    : aliased C.char_array := C.To_C(Name);
    Ch_Caption : aliased C.char_array := C.To_C(Caption);
    Win        : aliased Window_Access;
  begin
    if (Modal)               then C_Flags := C_Flags or WINDOW_MODAL;         end if;
    if (Main)                then C_Flags := C_Flags or WINDOW_MAIN;          end if;
    if (Keep_Above)          then C_Flags := C_Flags or WINDOW_KEEP_ABOVE;    end if;
    if (Keep_Below)          then C_Flags := C_Flags or WINDOW_KEEP_BELOW;    end if;
    if (Deny_Focus)          then C_Flags := C_Flags or WINDOW_DENY_FOCUS;    end if;
    if (not Titlebar)        then C_Flags := C_Flags or WINDOW_NO_TITLE;      end if;
    if (not Borders)         then C_Flags := C_Flags or WINDOW_NO_BORDERS;    end if;
    if (not H_Resize)        then C_Flags := C_Flags or WINDOW_NO_H_RESIZE;   end if;
    if (not V_Resize)        then C_Flags := C_Flags or WINDOW_NO_V_RESIZE;   end if;
    if (not Close_Button)    then C_Flags := C_Flags or WINDOW_NO_CLOSE;      end if;
    if (not Minimize_Button) then C_Flags := C_Flags or WINDOW_NO_MINIMIZE;   end if;
    if (not Maximize_Button) then C_Flags := C_Flags or WINDOW_NO_MAXIMIZE;   end if;
    if (Tileable)            then C_Flags := C_Flags or WINDOW_TILEABLE;      end if;
    if (not BG_Fill)         then C_Flags := C_Flags or WINDOW_NO_BACKGROUND; end if;
    if (Main)                then C_Flags := C_Flags or WINDOW_MAIN;          end if;
    if (H_Maximize)          then C_Flags := C_Flags or WINDOW_H_MAXIMIZE;    end if;
    if (V_Maximize)          then C_Flags := C_Flags or WINDOW_V_MAXIMIZE;    end if;
    if (not Movable)         then C_Flags := C_Flags or WINDOW_NO_MOVE;       end if;
    if (Inherit_Zoom)        then C_Flags := C_Flags or WINDOW_INHERIT_ZOOM;  end if;
    if (Fade_In)             then C_Flags := C_Flags or WINDOW_FADE_IN;       end if;
    if (Fade_Out)            then C_Flags := C_Flags or WINDOW_FADE_Out;      end if;

    if (Driver /= null) then
      Win := AG_WindowNewUnder(Driver, C_Flags);
      if (Name /= "") then
        Agar.Object.Set_Name
          (Object => Window_to_Object(Win),
           Name   => Name);
      end if;
    else
      if (Name /= "") then
        Win := AG_WindowNewNamedS
          (Flags => C_Flags,
           Name  => CS.To_Chars_Ptr(Ch_Name'Unchecked_Access));
      else
        Win := AG_WindowNew(C_Flags);
      end if;
    end if;

    if (Win = null) then
      raise Program_Error with Agar.Error.Get_Error;
    end if;

    if (Caption /= "") then
      AG_WindowSetCaptionS
        (Window  => Win,
         Caption => CS.To_Chars_Ptr(Ch_Caption'Unchecked_Access));
    end if;

    if (W /= 0 or H /= 0) then
      AG_WindowSetGeometryAligned
        (Window    => Win,
         Alignment => C.int(Alignment'Enum_Rep),
         W         => C.int(W),
         H         => C.int(H));
    end if;

    if (Min_W /= 0 or Min_H /= 0) then
      AG_WindowSetMinSize
        (Window => Win,
         W      => C.int(Min_W),
         H      => C.int(Min_H));
    end if;

    if (Maximized) then
      AG_WindowMaximize(Win);
    end if;
    if (Minimized) then
      AG_WindowMinimize(Win);
    end if;

    return (Win);
  end;

  --
  -- Return an access to an Agar window by name.
  -- Returns null if no such window exists.
  -- Lock_Drivers() and Unlock_Drivers() should be used.
  --
  function Find_Window
    (Name : in String) return Window_access
  is
    Ch_Name : aliased C.char_array := C.To_C(Name);
  begin
    return AG_WindowFind(CS.To_Chars_Ptr(Ch_Name'Unchecked_Access));
  end;

  --
  -- Change the title text of a window.
  --
  procedure Set_Window_Caption
    (Window  : in Window_not_null_Access;
     Caption : in String)
  is
    Ch_Caption : aliased C.char_array := C.To_C(Caption);
  begin
    AG_WindowSetCaptionS
      (Window  => Window,
       Caption => CS.To_Chars_Ptr(Ch_Caption'Unchecked_Access));
  end;

  --
  -- Return the current title text of a window.
  --
  function Get_Window_Caption
    (Window : in Window_not_null_Access) return String
  is
  begin
    return C.To_Ada( CS.Value(ag_window_get_caption(Window)) );
  end;

  --
  -- Set the icon of a window from the contents of the given graphics surface.
  --
  procedure Set_Window_Icon
    (Window  : in Window_not_null_Access;
     Icon    : in SU.Surface_not_null_Access)
  is begin
    AG_WindowSetIcon
      (Window  => Window,
       Icon    => Icon);
  end;

  --
  -- Set the width in pixels of the window borders and resize control bar.
  --
  procedure Set_Window_Borders
    (Window       : in Window_not_null_Access;
     W_Sides      : in Natural := 0;
     W_Bottom     : in Natural := 8;
     W_Resize_Bar : in Natural := 16)
  is
  begin
    AG_WindowSetSideBorders
      (Window => Window,
       W      => C.int(W_Sides));
    AG_WindowSetBottomBorder
      (Window => Window,
       W      => C.int(W_Bottom));

    Window.Resize_Control_W := C.int(W_Resize_Bar);
  end;

  --
  -- Get the width in pixels of the window borders and resize control bar.
  --
  procedure Get_Window_Borders
    (Window       : in Window_not_null_Access;
     W_Sides      : out Natural;
     W_Bottom     : out Natural;
     W_Resize_Bar : out Natural)
  is begin
    W_Bottom     := Natural(Window.Bottom_Border_W);
    W_Sides      := Natural(Window.Side_Borders_W);
    W_Resize_Bar := Natural(Window.Resize_Control_W);
  end;

  --
  -- Assign a standard event handler to the "window-close" event.
  --
  procedure Set_Window_Close_Action
    (Window : in Window_not_null_Access;
     Action : in Window_Close_Action)
  is begin
    AG_WindowSetCloseAction
      (Window => Window,
       Action => Action'Enum_Rep);
  end;

  --
  -- Move a window by a relative distance in pixels.
  --
  procedure Move_Window
    (Window : in Window_not_null_Access;
     X_Rel  : in Integer := 0;
     Y_Rel  : in Integer := 0)
  is begin
    AG_WindowMove
      (Window => Window,
       X_Rel   => C.int(X_Rel),
       Y_Rel   => C.int(Y_Rel));
  end;

  --
  -- Set the minimum size of a window in pixels.
  --
  procedure Set_Window_Minimium_Size
    (Window : in Window_not_null_Access;
     W      : in Natural := 0;
     H      : in Natural := 0)
  is begin
    AG_WindowSetMinSize
      (Window => Window,
       W      => C.int(W),
       H      => C.int(H));
  end;

  --
  -- Set the minimum size of a window in % of available desktop area.
  --
  procedure Set_Window_Minimium_Size_Pct
    (Window : in Window_not_null_Access;
     W_Pct  : in Natural := 0;
     H_Pct  : in Natural := 0)
  is begin
    AG_WindowSetMinSizePct
      (Window => Window,
       W_Pct  => C.int(W_Pct),
       H_Pct  => C.int(H_Pct));
  end;

  --
  -- Set the position and size of a window in pixels.
  -- Auto-place if X/Y is -1. Auto-size if W/H is -1.
  --
  procedure Set_Window_Geometry
    (Window : in Window_not_null_Access;
     X,Y    : in Integer := -1;
     W,H    : in Integer := -1)
  is begin
    AG_WindowSetGeometry
      (Window => Window,
       X      => C.int(X),
       Y      => C.int(Y),
       W      => C.int(W),
       H      => C.int(H));
  end;

  --
  -- Set the desktop alignment and size of a window (in pixels).
  -- Auto-size if W/H is -1.
  --
  procedure Set_Window_Geometry_Aligned
    (Window    : in Window_not_null_Access;
     Alignment : in Window_Alignment := MIDDLE_CENTER;
     W,H       : in Integer := -1)
  is begin
    AG_WindowSetGeometryAligned
      (Window    => Window,
       Alignment => Alignment'Enum_Rep,
       W         => C.int(W),
       H         => C.int(H));
  end;

  --
  -- Set the desktop alignment and size of a window (in % of desktop area).
  --
  procedure Set_Window_Geometry_Aligned_Pct
    (Window    : in Window_not_null_Access;
     Alignment : in Window_Alignment := MIDDLE_CENTER;
     W_Pct     : in Positive := 50;
     H_Pct     : in Positive := 33)
  is begin
    AG_WindowSetGeometryAlignedPct
      (Window    => Window,
       Alignment => Alignment'Enum_Rep,
       W_Pct     => C.int(W_Pct),
       H_Pct     => C.int(H_Pct));
  end;

  --
  -- Compute the X,Y coordinates required to align the window in the parent
  -- desktop area (per the window's alignment setting).
  --
  procedure Compute_Window_Alignment 
    (Window : in Window_not_null_Access;
     X,Y    : out Integer)
  is
     SA : aliased SizeAlloc;
  begin
     AG_WindowComputeAlignment
       (Window => Window,
        SA     => SA'Unchecked_Access);
     X := Integer(SA.x);
     Y := Integer(SA.y);
  end;

  --
  -- Set the opacity of a window (for compositing window managers).
  --
  procedure Set_Window_Opacity
    (Window  : in Window_not_null_Access;
     Opacity : in Window_Opacity)
  is begin
    AG_WindowSetOpacity
      (Window  => Window,
       Opacity => C.C_float(Opacity));
  end;

  --
  -- Enable slow fade-in on a window (for compositing window managers).
  --
  procedure Set_Window_Fade_In
    (Window     : in Window_not_null_Access;
     Fade_Time  : in Window_Fade_Duration := 0.06;
     Fade_Delta : in Window_Fade_Delta    := 0.2)
  is begin
    AG_WindowSetFadeIn
      (Window     => Window,
       Fade_Time  => C.C_float(Fade_Time),
       Fade_Delta => C.C_float(Fade_Delta));
  end;

  --
  -- Enable slow fade-out on a window (for compositing window managers).
  --
  procedure Set_Window_Fade_Out
    (Window     : in Window_not_null_Access;
     Fade_Time  : in Window_Fade_Duration := 0.06;
     Fade_Delta : in Window_Fade_Delta    := 0.2)
  is begin
    AG_WindowSetFadeOut
      (Window     => Window,
       Fade_Time  => C.C_float(Fade_Time),
       Fade_Delta => C.C_float(Fade_Delta));
  end;

  --
  -- Set the zoom level on a window.
  --
  procedure Set_Window_Zoom
    (Window : in Window_not_null_Access;
     Level  : in Window_Zoom_Level := 100)
  is begin
    AG_WindowSetZoom
      (Window => Window,
       Level  => C.int(Level));
  end;

  --
  -- Restore saved window geometry after a Maximize/Minimize.
  --
  procedure Restore_Window_Geometry
    (Window : in Window_not_null_Access)
  is
    Ret_Ignore : aliased C.int;
  begin
    Ret_Ignore := AG_WindowRestoreGeometry(Window);
  end;

  --
  -- Move any pinned windows by a relative displacement in pixels.
  -- Intended to be called from low-level Driver code.
  --
  procedure Move_Pinned_Windows
    (Parent      : in Window_not_null_Access;
     X_Rel,Y_Rel : in Integer)
  is begin
    AG_WindowMovePinned
      (window => Parent,
       X_Rel  => C.int(X_Rel),
       Y_Rel  => C.int(Y_Rel));
  end;

  --
  -- Return an access to the currently focused window (or null).
  -- The caller should use Lock_Drivers().
  --
  function Is_Window_Focused
    (Window : Window_not_null_Access) return Boolean
  is begin
    return 1 = AG_WindowIsFocused(Window);
  end;

  --
  -- Set the input focus on the given window (by name).
  --
  procedure Focus_Window
    (Name : in String)
  is
    Ch_Name : aliased C.char_array := C.To_C(Name);
    Ret_Val : aliased C.int;
  begin
    Ret_Val := AG_WindowFocusNamed
      (Name => CS.To_Chars_Ptr(Ch_Name'Unchecked_Access));
  end;

  --
  -- Set the input focus on the given window (by display coordinates).
  -- This operation is specific to single-window drivers.
  --
  procedure Focus_Window
    (Driver : in Driver_SW_not_null_Access;
     X,Y    : in Integer)
  is
    Ret_Val : aliased C.int;
  begin 
    Ret_Val := AG_WindowFocusAtPos
      (Driver => Driver,
       X      => C.int(X),
       Y      => C.int(Y));
  end;

  --
  -- Move the input focus to the next Agar widget in the window.
  --
  procedure Cycle_Window_Focus
    (Window        : in Window_not_null_Access;
     Reverse_Order : in Boolean := False)
  is begin
    if (Reverse_Order) then
      AG_WindowCycleFocus
        (Window        => Window,
         Reverse_Order => C.int(1));
    else
      AG_WindowCycleFocus
        (Window        => Window,
         Reverse_Order => C.int(0));
    end if;
  end;

  --
  -- Configure a new cursor-change area over Rect with a standard Agar cursor.
  --
  function Map_Cursor
    (Widget : in Widget_not_null_Access;
     Rect   : in SU.Rect_Access;
     Cursor : in Standard_Cursor) return Cursor_Area_not_null_Access
  is
    Cursor_Area : Cursor_Area_Access;
  begin
    Cursor_Area := AG_MapStockCursor
      (Widget => Widget,
       Rect   => Rect,
       Cursor => Cursor'Enum_Rep);
    if (Cursor_Area = null) then 
      raise Program_Error with Agar.Error.Get_Error;
    else
      return Cursor_Area;
    end if;
  end;

  --
  -- Return the visibility status of a window.
  --
  function Window_Is_Visible
    (Window : in Window_not_null_Access) return Boolean
  is begin
    return (Window.Visible = C.int(1));
  end;

  --
  -- Return an access to the parent window of a widget (or fatal error if null).
  -- The Drivers and Window object must be locked.
  --
  function Parent_Window
    (Widget : in Widget_not_null_Access) return Window_not_null_Access
  is begin
    if (Widget.Parent_Window /= null) then
      return Widget.Parent_Window;
    else
      raise Program_Error with "No parent window";
    end if;
  end;

  --
  -- Set an explicit child widget position in pixels.
  --
  procedure Set_Widget_Position
    (Widget : in Widget_not_null_Access;
     X,Y    : in Integer := 0)
  is begin
    AG_WidgetSetPosition
      (Widget => Widget,
       X      => C.int(X),
       Y      => C.int(Y));
  end;

  --
  -- Set an explicit child widget size in pixels.
  --
  procedure Set_Widget_Size
    (Widget : in Widget_not_null_Access;
     W,H    : in Natural)
  is begin
    AG_WidgetSetSize
      (Widget => Widget,
       W      => C.int(W),
       H      => C.int(H));
  end;

  --
  -- Set an explicit child widget position and size in pixels.
  --
  procedure Set_Widget_Geometry
    (Widget : in Widget_not_null_Access;
     X,Y    : in Integer := 0;
     W,H    : in Natural)
  is
    Rect : aliased SU.AG_Rect;
  begin
    Rect.X := C.int(X);
    Rect.Y := C.int(Y);
    Rect.W := C.int(W);
    Rect.X := C.int(H);
    AG_WidgetSetGeometry
      (Widget => Widget,
       Rect   => Rect'Unchecked_Access);
  end;

end Agar.Widget;
