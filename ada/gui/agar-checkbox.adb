------------------------------------------------------------------------------
--                             AGAR GUI LIBRARY                             --
--                        A G A R  . C H E C K B O X                        --
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

package body Agar.Checkbox is

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
     Init_State : in Boolean := False) return Checkbox_not_null_Access
  is
    Ch_Text  : aliased C.char_array := C.To_C(Text);
    C_Flags  : aliased C.unsigned := 0;
    Checkbox : Checkbox_Access;
  begin
    if (H_Fill)        then C_Flags := C_Flags or AG_CHECKBOX_HFILL;     end if;
    if (V_Fill)        then C_Flags := C_Flags or AG_CHECKBOX_VFILL;     end if;
    if (Expand)        then C_Flags := C_Flags or AG_CHECKBOX_EXPAND;    end if;
    if (Inverted)      then C_Flags := C_Flags or AG_CHECKBOX_INVERT;  end if;
    if (Exclusive)     then C_Flags := C_Flags or AG_CHECKBOX_EXCL;      end if;
    if (Init_State)    then C_Flags := C_Flags or AG_CHECKBOX_SET;       end if;

    if (Text /= "") then
      Checkbox := AG_CheckboxNewS
        (Parent => Parent,
         Flags  => C_Flags,
         Text   => CS.To_Chars_Ptr(Ch_Text'Unchecked_Access));
    else
      Checkbox := AG_CheckboxNewS
        (Parent => Parent,
         Flags  => C_Flags,
         Text   => CS.To_Chars_Ptr(null));
    end if;

    if (not Focusable) then
      AGW.Set_Focusable
        (Widget => Checkbox_To_Widget(Checkbox),
         Enable => False);
    end if;

    return (Checkbox);
  end;

  --
  -- Define whether the checkbox can be focused.
  --
  procedure Set_Checkbox_Focusable
    (Checkbox  : in Checkbox_not_null_Access;
     Focusable : in Boolean)
  is begin
    AGW.Set_Focusable
      (Widget => Checkbox_To_Widget(Checkbox),
       Enable => Focusable);
  end;

  --
  -- Set inverted mode (invert boolean state).
  --
  procedure Set_Checkbox_Inverted
    (Checkbox : in Checkbox_not_null_Access;
     Inverted : in Boolean)
  is begin
    AGO.Lock(Checkbox_To_Object(Checkbox));

    if (Inverted) then
      Checkbox.Flags := Checkbox.Flags or AG_CHECKBOX_INVERT;
    else
      Checkbox.Flags := Checkbox.Flags and not AG_CHECKBOX_INVERT;
    end if;

    AGW.Redraw(Checkbox_To_Widget(Checkbox));
    AGO.UnLock(Checkbox_To_Object(Checkbox));
  end;

  --
  -- Return the current boolean state of the checkbox.
  --
  function Get_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access) return Boolean
  is begin
    return (AG_CheckboxGetState(Checkbox) /= C.int(0));
  end;

  --
  -- Set the boolean state of the checkbox.
  --
  procedure Set_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access;
     State    : in Boolean)
  is begin
    if (State) then
      AG_CheckboxSetState
        (Checkbox => Checkbox,
         State    => C.int(1));
    else
      AG_CheckboxSetState
        (Checkbox => Checkbox,
         State    => C.int(0));
    end if;
  end;

  --
  -- Set the boolean state of the checkbox and return previous state.
  --
  function Set_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access;
     State    : in Boolean) return Boolean
  is
    Prev_State : Boolean;
  begin
    AGO.Lock(Checkbox_To_Object(Checkbox));

    Prev_State := (AG_CheckboxGetState(Checkbox) /= C.int(0));

    if (State) then
      AG_CheckboxSetState
        (Checkbox => Checkbox,
         State    => C.int(1));
    else
      AG_CheckboxSetState
        (Checkbox => Checkbox,
         State    => C.int(0));
    end if;

    AGO.Unlock(Checkbox_To_Object(Checkbox));

    Return (Prev_State);
  end;

  --
  -- Toggle the state of the checkbox atomically.
  --
  procedure Toggle_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access)
  is begin
    AG_CheckboxToggle(Checkbox);
  end;

  --
  -- Toggle the state of the checkbox atomically and return the new state.
  --
  function Toggle_Checkbox_State
    (Checkbox : in Checkbox_not_null_Access) return Boolean
  is
    New_State : Boolean;
  begin
    AGO.Lock(Checkbox_To_Object(Checkbox));

    AG_CheckboxToggle(Checkbox);
    New_State := (AG_CheckboxGetState(Checkbox) /= C.int(0));

    AGO.Unlock(Checkbox_To_Object(Checkbox));
    return (New_State);
  end;

  --
  -- Update the text label for the checkbox.
  --
  procedure Set_Checkbox_Text
    (Checkbox : in Checkbox_not_null_Access;
     Text     : in String)
  is
    Ch_Text : aliased C.char_array := C.To_C(Text);
  begin
    AG_CheckboxTextS
      (Checkbox => Checkbox,
       Text     => CS.To_Chars_Ptr(Ch_Text'Unchecked_Access));
  end;

end Agar.Checkbox;
