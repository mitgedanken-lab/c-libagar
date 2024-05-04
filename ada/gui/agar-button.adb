------------------------------------------------------------------------------
--                             AGAR GUI LIBRARY                             --
--                          A G A R  . B U T T O N                          --
--                                 B o d y                                  --
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

package body Agar.Button is

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
     Crop       : in Boolean := False) return Button_not_null_Access
  is
    Ch_Text : aliased C.char_array := C.To_C(Text);
    C_Flags : aliased C.unsigned := 0;
    Button : Button_Access;
  begin
    if (not Focusable) then C_Flags := C_Flags or AG_BUTTON_NO_FOCUS;  end if;
    if (Sticky)        then C_Flags := C_Flags or AG_BUTTON_STICKY;    end if;
    if (Repeat)        then C_Flags := C_Flags or AG_BUTTON_REPEAT;    end if;
    if (H_Fill)        then C_Flags := C_Flags or AG_BUTTON_HFILL;     end if;
    if (V_Fill)        then C_Flags := C_Flags or AG_BUTTON_VFILL;     end if;
    if (Expand)        then C_Flags := C_Flags or AG_BUTTON_EXPAND;    end if;
    if (Inverted)      then C_Flags := C_Flags or AG_BUTTON_INVERTED;  end if;
    if (Exclusive)     then C_Flags := C_Flags or AG_BUTTON_EXCL;      end if;
    if (Init_State)    then C_Flags := C_Flags or AG_BUTTON_SET;       end if;
    if (Crop)          then C_Flags := C_Flags or AG_BUTTON_CROP;      end if;

    if (Text /= "") then
      Button := AG_ButtonNewS
        (Parent => Parent,
         Flags  => C_Flags,
         Text   => CS.To_Chars_Ptr(Ch_Text'Unchecked_Access));
    else
      Button := AG_ButtonNewS
        (Parent => Parent,
         Flags  => C_Flags,
         Text   => CS.To_Chars_Ptr(null));
    end if;

    if (Surface /= null) then
      AG_ButtonSurface
        (Button  => Button,
         Surface => Surface);
    end if;

    return (Button);
  end;

  --
  -- Define whether the button can be focused.
  --
  procedure Set_Button_Focusable
    (Button    : in Button_not_null_Access;
     Focusable : in Boolean)
  is begin
    if (Focusable) then
      AG_ButtonSetFocusable
        (Button    => Button,
         Focusable => C.int(1));
    else
      AG_ButtonSetFocusable
        (Button    => Button,
         Focusable => C.int(0));
    end if;
  end;

  --
  -- Set the sticky behavior mode.
  --
  procedure Set_Button_Sticky
    (Button : in Button_not_null_Access;
     Sticky : in Boolean)
  is begin
    if (Sticky) then
      AG_ButtonSetSticky
        (Button => Button,
         Sticky => C.int(1));
    else
      AG_ButtonSetSticky
        (Button => Button,
         Sticky => C.int(0));
    end if;
  end;

  --
  -- Set inverted mode (invert boolean state).
  --
  procedure Set_Button_Inverted
    (Button   : in Button_not_null_Access;
     Inverted : in Boolean)
  is begin
    if (Inverted) then
      AG_ButtonSetInverted
        (Button   => Button,
         Inverted => C.int(1));
    else
      AG_ButtonSetInverted
        (Button   => Button,
         Inverted => C.int(0));
    end if;
  end;

  --
  -- Return the current boolean state of the button.
  --
  function Get_Button_State
    (Button : in Button_not_null_Access) return Boolean
  is begin
    return (AG_ButtonGetState(Button) /= C.int(0));
  end;

  --
  -- Set the boolean state of the button.
  --
  procedure Set_Button_State
    (Button : in Button_not_null_Access;
     State  : in Boolean)
  is
    Prev_State : aliased C.int;
  begin
    if (State) then
      Prev_State := AG_ButtonSetState
        (Button => Button,
         State  => C.int(1));
    else
      Prev_State := AG_ButtonSetState
        (Button => Button,
         State  => C.int(0));
    end if;
  end;

  --
  -- Set the boolean state of the button and return previous state.
  --
  function Set_Button_State
    (Button : in Button_not_null_Access;
     State  : in Boolean) return Boolean
  is
    Prev_State : aliased C.int;
  begin
    if (State) then
      Prev_State := AG_ButtonSetState
        (Button => Button,
         State  => C.int(1));
    else
      Prev_State := AG_ButtonSetState
        (Button => Button,
         State  => C.int(0));
    end if;

    Return (Prev_State /= C.int(0));
  end;

  --
  -- Toggle the state of the button atomically.
  --
  procedure Toggle_Button_State
    (Button : in Button_not_null_Access)
  is
    New_State : aliased C.int;
  begin
    New_State := AG_ButtonToggle(Button);
  end;

  --
  -- Toggle the state of the button atomically and return the new state.
  --
  function Toggle_Button_State
    (Button : in Button_not_null_Access) return Boolean
  is begin
    return (AG_ButtonToggle(Button) /= C.int(0));
  end;

  --
  -- Set the text horizontal justification mode.
  --
  procedure Set_Button_Justify
    (Button  : in Button_not_null_Access;
     Justify : in AGT.Text_Justify := AGT.CENTER)
  is begin
    AG_ButtonJustify
      (Button  => Button,
       Justify => Justify'Enum_Rep);
  end;

  --
  -- Set the text vertical alignment mode.
  --
  procedure Set_Button_V_Align
    (Button  : in Button_not_null_Access;
     V_Align : in AGT.Text_Valign := AGT.MIDDLE)
  is begin
    AG_ButtonValign
      (Button  => Button,
       V_Align => V_Align'Enum_Rep);
  end;

  --
  -- Use a given graphics surface as a label for the button.
  -- If Surface is null, delete any previously set graphics surface.
  -- If No_Dup is False (the default), use a copy of Surface internally.
  -- If No_Dup is True, re-use the surface without copying (dangerous).
  --
  procedure Set_Button_Surface
    (Button  : in Button_not_null_Access;
     Surface : in AGSU.Surface_Access;
     No_Dup  : in Boolean := False)
  is begin
    if (No_Dup) then
      AG_ButtonSurface
        (Button  => Button,
         Surface => Surface);
    else
      AG_ButtonSurfaceNODUP
        (Button  => Button,
         Surface => Surface);
    end if;
  end;

  --
  -- Set Repeat mode. If Repeat mode is enabled, pushing the button will
  -- cause multiple events to fire repeatedly at a regular interval.
  --
  procedure Set_Button_Repeat_Mode
    (Button : in Button_not_null_Access;
     Repeat : in Boolean)
  is begin
    if (Repeat) then
      AG_ButtonSetRepeatMode
        (Button => Button,
         Repeat => C.int(1));
    else
      AG_ButtonSetRepeatMode
        (Button => Button,
         Repeat => C.int(0));
    end if;
  end;

  --
  -- Update the text label for the button.
  --
  procedure Set_Button_Text
    (Button : in Button_not_null_Access;
     Text   : in String)
  is
    Ch_Text : aliased C.char_array := C.To_C(Text);
  begin
    AG_ButtonTextS
      (Button => Button,
       Text   => CS.To_Chars_Ptr(Ch_Text'Unchecked_Access));
  end;

end Agar.Button;
