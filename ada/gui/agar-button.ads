------------------------------------------------------------------------------
--                             AGAR GUI LIBRARY                             --
--                          A G A R  . B U T T O N                          --
--                                 S p e c                                  --
------------------------------------------------------------------------------
with Interfaces.C;
with Interfaces.C.Strings;
with System;
with Agar.Object;
with Agar.Timer;
with Agar.Event;
with Agar.Surface; use Agar.Surface;
with Agar.Text;
with Agar.Widget;

--
-- Push-button widget. It can display a text label or an image.
-- It can trigger events or it can be bound to a boolean variable.
--

package Agar.Button is
  package C renames Interfaces.C;
  package CS renames Interfaces.C.Strings;
  package AGO renames Agar.Object;
  package AGE renames Agar.Event;
  package AGSU renames Agar.Surface;
  package AGT renames Agar.Text;
  package AGW renames Agar.Widget;

  use type C.int;
  use type C.unsigned;

  -- Flags --
  AG_BUTTON_NO_FOCUS      : constant C.unsigned := 16#00_01#;
  AG_BUTTON_STICKY        : constant C.unsigned := 16#00_02#;
  AG_BUTTON_PRESSING      : constant C.unsigned := 16#00_04#;
  AG_BUTTON_REPEAT        : constant C.unsigned := 16#00_08#;
  AG_BUTTON_HFILL         : constant C.unsigned := 16#00_10#;
  AG_BUTTON_VFILL         : constant C.unsigned := 16#00_20#;
  AG_BUTTON_ALIGN_LEFT    : constant C.unsigned := 16#00_40#;
  AG_BUTTON_ALIGN_RIGHT   : constant C.unsigned := 16#00_80#;
  AG_BUTTON_VALIGN_TOP    : constant C.unsigned := 16#01_00#;
  AG_BUTTON_VALIGN_BOTTOM : constant C.unsigned := 16#02_00#;
  AG_BUTTON_INVERTED      : constant C.unsigned := 16#04_00#;
  AG_BUTTON_KEYDOWN       : constant C.unsigned := 16#08_00#;
  AG_BUTTON_EXCL          : constant C.unsigned := 16#10_00#;
  AG_BUTTON_NOEXCL        : constant C.unsigned := 16#20_00#;
  AG_BUTTON_SET           : constant C.unsigned := 16#40_00#;
  AG_BUTTON_CROP          : constant C.unsigned := 16#80_00#;
  AG_BUTTON_EXPAND        : constant C.unsigned := AG_BUTTON_HFILL or AG_BUTTON_VFILL;

  -- Context for REPEAT mode --
  type Button_Repeat_Ctx is limited record
    Delay_Timer    : Agar.Timer.Timer;          -- Delay until key repeat
    Interval_Timer : Agar.Timer.Timer;          -- Interval between repetitions
  end record
    with Convention => C;

  type Button_Repeat_Ctx_Access is access all Button_Repeat_Ctx with Convention => C;

  ---------------------------------
  -- Agar Button Widget Instance --
  ---------------------------------
  type Button is limited record
    Super         : aliased Agar.Widget.Widget; -- ( Object -> Widget -> Button )
    Flags         : C.unsigned;
    State         : C.int;                      -- Default state variable binding
    Surface_Label : C.int;                      -- Rendered text label (or -1)
    Surface_Src   : C.int;                      -- Specified graphical surface (or -1)
    Justify       : AGT.Text_Justify;           -- Horizontal alignment mode
    V_Align       : AGT.Text_Valign;            -- Vertical alignment mode
    W_Req, H_Req  : C.int;                      -- Size hint / requisition
    Label_Text    : CS.chars_ptr;               -- Text label (optional)
    Repeat_Ctx    : Button_Repeat_Ctx_Access;   -- Context for REPEAT option
  end record
    with Convention => C;

  type Button_Access is access all Button with Convention => C;
  subtype Button_not_null_Access is not null Button_Access;

  --
  -- Create a new Button widget.
  --
  function New_Button
    (Parent     : in AGW.Widget_Access;
     Text       : in String := "";
     Surface    : in AGSU.Surface_Access := null;
     Focusable  : in Boolean := True;
     Sticky     : in Boolean := False;
     Repeat     : in Boolean := False;
     H_Fill     : in Boolean := False;
     V_Fill     : in Boolean := False;
     Expand     : in Boolean := False;
     Inverted   : in Boolean := False;
     Exclusive  : in Boolean := False;
     Init_State : in Boolean := False;
     Crop       : in Boolean := False) return Button_not_null_Access;

  function Button_To_Widget
    (Button : in Button_not_null_Access) return AGW.Widget_not_null_Access
    with Import, Convention => C, Link_Name => "ag_button_to_widget";

  function Button_To_Object
    (Button : in Button_not_null_Access) return AGO.Object_not_null_Access
    with Import, Convention => C, Link_Name => "ag_button_to_object";

  --
  -- Define whether the button can be focused.
  --
  procedure Set_Button_Focusable
    (Button    : in Button_not_null_Access;
     Focusable : in Boolean);

  --
  -- Set the sticky behavior mode.
  --
  procedure Set_Button_Sticky
    (Button : in Button_not_null_Access;
     Sticky : in Boolean);

  --
  -- Set inverted mode (invert boolean state).
  --
  procedure Set_Button_Inverted
    (Button   : in Button_not_null_Access;
     Inverted : in Boolean);

  --
  -- Return the current boolean state of the button.
  --
  function Get_Button_State
    (Button : in Button_not_null_Access) return Boolean;

  --
  -- Set the boolean state of the button.
  --
  procedure Set_Button_State
    (Button : in Button_not_null_Access;
     State  : in Boolean);

  --
  -- Set the boolean state of the button and return previous state.
  --
  function Set_Button_State
    (Button : in Button_not_null_Access;
     State  : in Boolean) return Boolean;

  --
  -- Toggle the state of the button atomically.
  --
  procedure Toggle_Button_State
    (Button : in Button_not_null_Access);

  --
  -- Toggle the state of the button atomically and return the new state.
  --
  function Toggle_Button_State
    (Button : in Button_not_null_Access) return Boolean;

  --
  -- Set the text horizontal justification mode.
  --
  procedure Set_Button_Justify
    (Button  : in Button_not_null_Access;
     Justify : in AGT.Text_Justify := AGT.CENTER);

  --
  -- Set the text vertical alignment mode.
  --
  procedure Set_Button_V_Align
    (Button  : in Button_not_null_Access;
     V_Align : in AGT.Text_Valign := AGT.MIDDLE);

  --
  -- Use a given graphics surface as a label for the button.
  -- If Surface is null, delete any previously set graphics surface.
  -- If No_Dup is False (the default), use a copy of Surface internally.
  -- If No_Dup is True, re-use the surface without copying (dangerous).
  --
  procedure Set_Button_Surface
    (Button  : in Button_not_null_Access;
     Surface : in AGSU.Surface_Access;
     No_Dup  : in Boolean := False);

  --
  -- Set Repeat mode. If Repeat mode is enabled, pushing the button will
  -- cause multiple events to fire repeatedly at a regular interval.
  --
  procedure Set_Button_Repeat_Mode
    (Button : in Button_not_null_Access;
     Repeat : in Boolean);

  --
  -- Update the text label for the button.
  --
  procedure Set_Button_Text
    (Button : in Button_not_null_Access;
     Text   : in String);

  private

  function AG_ButtonNewS
    (Parent : in AGW.Widget_Access;
     Flags  : in C.unsigned;
     Text   : in CS.chars_ptr) return Button_not_null_Access
    with Import, Convention => C, Link_Name => "AG_ButtonNewS";

  procedure AG_ButtonSetFocusable
    (Button    : in Button_not_null_Access;
     Focusable : in C.int)
    with Import, Convention => C, Link_Name => "AG_ButtonSetFocusable";

  procedure AG_ButtonSetSticky
    (Button : in Button_not_null_Access;
     Sticky : in C.int)
    with Import, Convention => C, Link_Name => "AG_ButtonSetSticky";

  procedure AG_ButtonSetInverted
    (Button   : in Button_not_null_Access;
     Inverted : in C.int)
    with Import, Convention => C, Link_Name => "AG_ButtonSetInverted";

  function AG_ButtonGetState
    (Button : in Button_not_null_Access) return C.int
    with Import, Convention => C, Link_Name => "AG_ButtonGetState";

  function AG_ButtonSetState
    (Button : in Button_not_null_Access;
     State  : in C.int) return C.int
    with Import, Convention => C, Link_Name => "AG_ButtonSetState";

  function AG_ButtonToggle
    (Button : in Button_not_null_Access) return C.int
    with Import, Convention => C, Link_Name => "AG_ButtonToggle";

  procedure AG_ButtonJustify
    (Button  : in Button_not_null_Access;
     Justify : in C.int)
    with Import, Convention => C, Link_Name => "AG_ButtonJustify";

  procedure AG_ButtonValign
    (Button  : in Button_not_null_Access;
     V_Align : in C.int)
    with Import, Convention => C, Link_Name => "AG_ButtonValign";

  procedure AG_ButtonSurface
    (Button  : in Button_not_null_Access;
     Surface : in AGSU.Surface_Access)
    with Import, Convention => C, Link_Name => "AG_ButtonSurface";

  procedure AG_ButtonSurfaceNODUP
    (Button  : in Button_not_null_Access;
     Surface : in AGSU.Surface_Access)
    with Import, Convention => C, Link_Name => "AG_ButtonSurfaceNODUP";

  procedure AG_ButtonSetRepeatMode
    (Button : in Button_not_null_Access;
     Repeat : in C.int)
    with Import, Convention => C, Link_Name => "AG_ButtonSetRepeatMode";

  procedure AG_ButtonTextS
    (Button : in Button_not_null_Access;
     Text   : in CS.chars_ptr)
    with Import, Convention => C, Link_Name => "AG_ButtonTextS";

end Agar.Button;
