------------------------------------------------------------------------------
--                             AGAR GUI LIBRARY                             --
--                             A G A R .  B O X                             --
--                                 S p e c                                  --
------------------------------------------------------------------------------
with Interfaces.C;
with Interfaces.C.Strings;
with System;
with Agar.Object;
with Agar.Event;
with Agar.Widget;

--
-- General-purpose container widget which aligns and packs its widgets
-- horizontally or vertically (based on their size requisitions).
--

package Agar.Box is
  package C renames Interfaces.C;
  package CS renames Interfaces.C.Strings;
  package AGO renames Agar.Object;
  package AGE renames Agar.Event;
  package AGW renames Agar.Widget;

  use type C.int;
  use type C.unsigned;

  type Box_Orientation is
    (HORIZONTAL_BOX,          -- Widgets packed horizontally
     VERTICAL_BOX);           -- Widgets packed vertically
  for Box_Orientation'Size use C.int'Size;

  type Box_Graphic_Style is
    (NO_STYLE,                -- Undecorated
     BOX_STYLE,               -- 3D raised box
     WELL_STYLE,              -- 3D well
     PLAIN_STYLE);            -- Flat filled rectangle
  for Box_Graphic_Style'Size use C.int'Size;

  type Box_H_Alignment is (BOX_LEFT, BOX_CENTER, BOX_RIGHT);
  for Box_H_Alignment 'Size use C.int'Size;
  type Box_V_Alignment is (BOX_TOP, BOX_MIDDLE, BOX_BOTTOM);
  for Box_V_Alignment 'Size use C.int'Size;

  -- Flags --
  AG_BOX_HOMOGENOUS : constant C.unsigned := 16#00_01#;
  AG_BOX_H_FILL     : constant C.unsigned := 16#00_02#;
  AG_BOX_V_FILL     : constant C.unsigned := 16#00_04#;
  AG_BOX_SHADING    : constant C.unsigned := 16#00_08#;
  AG_BOX_NO_SPACING : constant C.unsigned := 16#00_10#;
  AG_BOX_EXPAND     : constant C.unsigned := AG_BOX_H_FILL or AG_BOX_V_FILL;

  ------------------------------
  -- Agar Box Widget Instance --
  ------------------------------
  type Box is limited record
    Super         : aliased Agar.Widget.Widget; -- ( Object -> Widget -> Box )
    Orientation   : Box_Orientation;            -- Horizontal or Vertical
    Graphic_Style : Box_Graphic_Style;          -- Decorations
    Flags         : C.unsigned;
    W_Pre, H_Pre  : C.int;                      -- Size hint (or -1)
    Depth         : C.int;                      -- Depth (for SHADING option)
    Label         : System.Address;             -- TODO text label
    H_Align       : Box_H_Alignment;            -- Horizontal alignment
    V_Align       : Box_V_Alignment;            -- Vertical alignment
  end record
    with Convention => C;

  type Box_Access is access all Box with Convention => C;
  subtype Box_not_null_Access is not null Box_Access;

  --
  -- Create a new Box container widget.
  --
  function New_Box
    (Parent      : in AGW.Widget_Access;
     Orientation : in Box_Orientation := VERTICAL_BOX;
     H_Fill      : in Boolean := False;
     V_Fill      : in Boolean := False;
     Expand      : in Boolean := False;
     Homogenous  : in Boolean := False;
     Spacing     : in Boolean := True;
     Shading     : in Boolean := False) return Box_not_null_Access;

  function Box_To_Widget
    (Box : in Box_not_null_Access) return AGW.Widget_not_null_Access
    with Import, Convention => C, Link_Name => "ag_box_to_widget";

  function Box_To_Object
    (Box : in Box_not_null_Access) return AGO.Object_not_null_Access
    with Import, Convention => C, Link_Name => "ag_box_to_object";

  --
  -- Set the graphical style of the Box.
  --
  procedure Set_Box_Style
    (Box   : in Box_not_null_Access;
     Style : in Box_Graphic_Style);

  --
  -- Set a text label to display on top of the Box.
  --
  procedure Set_Box_Label
    (Box  : in Box_not_null_Access;
     Text : in String);

  --
  -- Set a size hint in pixels.
  --
  procedure Set_Box_Size_Hint
    (Box : in Box_not_null_Access;
     W,H : in Integer := -1);

  --
  -- Set the Homogenous option.
  --
  procedure Set_Box_Homogenous
    (Box        : in Box_not_null_Access;
     Homogenous : in Boolean);

  --
  -- Set the depth in pixels for 3D graphic styles.
  --
  procedure Set_Box_Depth
    (Box   : in Box_not_null_Access;
     Depth : in Natural);

  --
  -- Set the orientation of the Box.
  --
  procedure Set_Box_Orientation
    (Box         : in Box_not_null_Access;
     Orientation : in Box_Orientation);

  --
  -- Set the horizontal alignment of the Box.
  --
  procedure Set_Box_H_Align
    (Box       : in Box_not_null_Access;
     Alignment : in Box_H_Alignment);

  --
  -- Set the vertical alignment of the Box.
  --
  procedure Set_Box_V_Align
    (Box       : in Box_not_null_Access;
     Alignment : in Box_V_Alignment);

  private

  function AG_BoxNew
    (Parent      : in AGW.Widget_Access;
     Orientation : in C.int;
     Flags       : in C.unsigned) return Box_not_null_Access
    with Import, Convention => C, Link_Name => "AG_BoxNew";

  procedure AG_BoxSetStyle
    (Box   : in Box_not_null_Access;
     Style : in C.int)
    with Import, Convention => C, Link_Name => "AG_BoxSetStyle";

  procedure AG_BoxSetLabelS
    (Box  : in Box_not_null_Access;
     Text : in CS.chars_ptr)
    with Import, Convention => C, Link_Name => "AG_BoxSetLabelS";

  procedure AG_BoxSizeHint
    (Box : in Box_not_null_Access;
     W,H : in C.int)
    with Import, Convention => C, Link_Name => "AG_BoxSizeHint";

  procedure AG_BoxSetHomogenous
    (Box    : in Box_not_null_Access;
     Enable : in C.int)
    with Import, Convention => C, Link_Name => "AG_BoxSetHomogenous";

  procedure AG_BoxSetDepth
    (Box   : in Box_not_null_Access;
     Depth : in C.int)
    with Import, Convention => C, Link_Name => "AG_BoxSetDepth";

  procedure AG_BoxSetType
    (Box         : in Box_not_null_Access;
     Orientation : in C.int)
    with Import, Convention => C, Link_Name => "AG_BoxSetType";

  procedure AG_BoxSetHorizAlign
    (Box       : in Box_not_null_Access;
     Alignment : in C.int)
    with Import, Convention => C, Link_Name => "AG_BoxSetHorizAlign";

  procedure AG_BoxSetVertAlign
    (Box       : in Box_not_null_Access;
     Alignment : in C.int)
    with Import, Convention => C, Link_Name => "AG_BoxSetVertAlign";

end Agar.Box;
