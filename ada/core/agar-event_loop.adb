------------------------------------------------------------------------------
--                            AGAR CORE LIBRARY                             --
--                      A G A R . E V E N T _ L O O P                       --
--                                 B o d y                                  --
--                                                                          --
-- Copyright (c) 2024, Julien Nadeau Carriere (vedge@csoft.net)             --
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
with Agar.Error;
with Ada.Text_IO;

package body Agar.Event_Loop is
  --
  -- Standard Agar event loop.
  --
  procedure Event_Loop
  is
    Return_Value : aliased C.int;
  begin
    Return_Value := AG_EventLoop;
    if Natural(Return_Value) /= 0 then
      Ada.Text_IO.Put_Line("AG_EventLoop(): " & Agar.Error.Get_Error);
    end if;
  end;

  procedure Terminate_Event_Loop
    (Return_Code : in Natural)
  is
  begin
    AG_Terminate(C.int(Return_Code));
  end;
  
end Agar.Event_Loop;
