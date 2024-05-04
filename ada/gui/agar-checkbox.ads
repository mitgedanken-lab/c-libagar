------------------------------------------------------------------------------
--                             AGAR GUI LIBRARY                             --
--                        A G A R  . C H E C K B O X                        --
--                                 S p e c                                  --
------------------------------------------------------------------------------
with Interfaces.C;
with Interfaces.C.Strings;
with System;
with Agar.Object;
with Agar.Event;
with Agar.Surface; use Agar.Surface;
with Agar.Widget;

--
-- Checkbox button with included text label.
-- It can trigger events or control a boolean variable.
--

package Agar.Checkbox is
  package C renames Interfaces.C;
  package CS renames Interfaces.C.Strings;
  package AGO renames Agar.Object;
  package AGW renames Agar.Widget;

  use type C.int;
  use type C.unsigned;

  -- Flags --
  AG_CHECKBOX_HFILL       : constant C.unsigned := 16#00_01#;
  AG_CHECKBOX_VFILL       : constant C.unsigned := 16#00_02#;
  AG_CHECKBOX_SET         : constant C.unsigned := 16#00_04#;
  AG_CHECKBOX_INVERT      : constant C.unsigned := 16#00_08#;
  AG_CHECKBOX_EXCL        : constant C.unsigned := 16#00_10#;
  AG_CHECKBOX_EXPAND      : constant C.unsigned := AG_CHECKBOX_HFILL or AG_CHECKBOX_VFILL;

  -----------------------------------
  -- Agar Checkbox Widget Instance --
  -----------------------------------
  type Checkbox is limited record
    Super          : aliased Agar.Widget.Widget; -- ( Object -> Widget -> Checkbox )
    Flags          : C.unsigned;
    State          : C.int;                      -- Default state variable binding
    Box_Width      : C.int;                      -- Width of box (pixels)
    Box_Offset     : C.int;                      -- Offset of box (pixels)
    W_Req, H_Req   : C.int;                      -- Size hint / requisition
    Surf_Checkmark : C.int;                      -- Rendered checkmark surface
    Surf_Label     : C.int;                      -- Rendered text label
    Label_Text     : CS.chars_ptr;               -- Text label string
  end record
    with Convention => C;

  type Checkbox_Access is access all Checkbox with Convention => C;
  subtype Checkbox_not_null_Access is not null Checkbox_Access;

  --
  -- Create a new Checkbox widget.
  --
  function New_Checkbox
    (Parent     : in AGW.Widget_Access;
     Text       : in String := "";
     Focusable  : in Boolean := True;
     H_Fill     : in Boolean := False;
     V_Fill     : in Boolean := False;
     Expand     : in Boolean := False;
     Inverted   : in Boolean := False;
     Exclusive  : in Boolean := False;
     Init_State : in Boolean := False) return Checkbox_not_null_Access;

  function Checkbox_To_Widget
    (Checkbox : in Checkbox_not_null_Access) return AGW.Widget_not_null_Access
    with Import, Convention => C, Link_Name => "ag_checkbox_to_widget";

  function Checkbox_To_Object
    (Checkbox : in Checkbox_not_null_Access) return AGO.Object_not_null_Access
    with Import, Convention => C, Link_Name => "ag_checkbox_to_object";

  --
  -- Define whether the checkbox can be focused.
  --
  procedure Set_Checkbox_Focusable
    (Checkbox  : in Checkbox_not_null_Access;
     Focusable : in Boolean);

  --
  -- Set inverted mode (invert boolean state).
  --
  procedure Set_Checkbox_Inverted
    (Checkbox : in Checkbox_not_null_Access;
     Inverted : in Boolean);

  --
  -- Return the current boolean state of the checkbox.
  --
  function Get_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access) return Boolean;

  --
  -- Set the boolean state of the checkbox.
  --
  procedure Set_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access;
     State    : in Boolean);

  --
  -- Set the boolean state of the checkbox and return previous state.
  --
  function Set_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access;
     State    : in Boolean) return Boolean;

  --
  -- Toggle the state of the checkbox atomically.
  --
  procedure Toggle_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access);

  --
  -- Toggle the state of the checkbox atomically and return the new state.
  --
  function Toggle_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access) return Boolean;

  --
  -- Update the text label for the checkbox.
  --
  procedure Set_Checkbox_Text
    (Checkbox : in Checkbox_not_null_Access;
     Text     : in String);

  private

  function AG_CheckboxNewS
    (Parent : in AGW.Widget_Access;
     Flags  : in C.unsigned;
     Text   : in CS.chars_ptr) return Checkbox_not_null_Access
    with Import, Convention => C, Link_Name => "AG_CheckboxNewS";

  function AG_CheckboxGetState
    (Checkbox  : in Checkbox_not_null_Access) return C.int
    with Import, Convention => C, Link_Name => "AG_CheckboxGetState";

  procedure AG_CheckboxSetState
    (Checkbox : in Checkbox_not_null_Access;
     State    : in C.int)
    with Import, Convention => C, Link_Name => "AG_CheckboxSetState";

  procedure AG_CheckboxToggle
    (Checkbox : in Checkbox_not_null_Access)
    with Import, Convention => C, Link_Name => "AG_CheckboxToggle";

  procedure AG_CheckboxTextS
    (Checkbox : in Checkbox_not_null_Access;
     Text     : in CS.chars_ptr)
    with Import, Convention => C, Link_Name => "AG_CheckboxTextS";

end Agar.Checkbox;
