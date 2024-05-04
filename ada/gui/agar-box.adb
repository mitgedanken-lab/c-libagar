------------------------------------------------------------------------------
--                             AGAR GUI LIBRARY                             --
--                             A G A R  . B O X                             --
--                                  B o d y                                 --
--                                                                          --
-- Copyright (c) 2024 Julien Nadeau Carriere (vedge@csoft.net)              --
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

package body Agar.Box is

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
     Shading     : in Boolean := False) return Box_not_null_Access
  is
    C_Flags : aliased C.unsigned := 0;
  begin
    if (H_Fill)      then C_Flags := C_Flags or AG_BOX_H_FILL;     end if;
    if (V_Fill)      then C_Flags := C_Flags or AG_BOX_V_FILL;     end if;
    if (Expand)      then C_Flags := C_Flags or AG_BOX_EXPAND;     end if;
    if (Shading)     then C_Flags := C_Flags or AG_BOX_SHADING;    end if;
    if (not Spacing) then C_Flags := C_Flags or AG_BOX_NO_SPACING; end if;
    if (Homogenous)  then C_Flags := C_Flags or AG_BOX_HOMOGENOUS; end if;

    return AG_BoxNew
      (Parent      => Parent,
       Orientation => Orientation'Enum_Rep,
       Flags       => C_Flags);
  end;

  --
  -- Set the graphical style of the Box.
  --
  procedure Set_Box_Style
    (Box   : in Box_not_null_Access;
     Style : in Box_Graphic_Style)
  is begin
    AG_BoxSetStyle
      (Box   => Box,
       Style => Style'Enum_Rep);
  end;

  --
  -- Set a text label to display on top of the Box.
  --
  procedure Set_Box_Label
    (Box  : in Box_not_null_Access;
     Text : in String)
  is
    Ch_Text : aliased C.char_array := C.To_C(Text);
  begin
    AG_BoxSetLabelS
      (Box  => Box,
       Text => CS.To_Chars_Ptr(Ch_Text'Unchecked_Access));
  end;

  --
  -- Set a size hint in pixels.
  --
  procedure Set_Box_Size_Hint
    (Box : in Box_not_null_Access;
     W,H : in Integer := -1)
  is begin
    AG_BoxSizeHint
      (Box => Box,
       W   => C.int(W),
       H   => C.int(H));
  end;

  --
  -- Set the Homogenous option.
  --
  procedure Set_Box_Homogenous
    (Box        : in Box_not_null_Access;
     Homogenous : in Boolean)
  is begin
    if (Homogenous) then
      AG_BoxSetHomogenous
        (Box    => Box,
         Enable => C.int(1));
    else
      AG_BoxSetHomogenous
        (Box    => Box,
         Enable => C.int(0));
    end if;
  end;

  --
  -- Set the depth in pixels for 3D graphic styles.
  --
  procedure Set_Box_Depth
    (Box   : in Box_not_null_Access;
     Depth : in Natural)
  is begin
    AG_BoxSetDepth
      (Box   => Box,
       Depth => C.int(Depth));
  end;

  --
  -- Set the orientation of the Box.
  --
  procedure Set_Box_Orientation
    (Box         : in Box_not_null_Access;
     Orientation : in Box_Orientation)
  is begin
    AG_BoxSetType
      (Box         => Box,
       Orientation => Orientation'Enum_Rep);
  end;

  --
  -- Set the horizontal alignment of the Box.
  --
  procedure Set_Box_H_Align
    (Box       : in Box_not_null_Access;
     Alignment : in Box_H_Alignment)
  is begin
    AG_BoxSetHorizAlign
      (Box       => Box,
       Alignment => Alignment'Enum_Rep);
  end;

  --
  -- Set the vertical alignment of the Box.
  --
  procedure Set_Box_V_Align
    (Box       : in Box_not_null_Access;
     Alignment : in Box_V_Alignment)
  is begin
    AG_BoxSetVertAlign
      (Box       => Box,
       Alignment => Alignment'Enum_Rep);
  end;

end Agar.Box;
