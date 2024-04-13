------------------------------------------------------------------------------
--                            AGAR CORE LIBRARY                             --
--                             A G A R . D S O                              --
--                                 B o d y                                  --
--                                                                          --
-- Copyright (c) 2018-2024, Julien Nadeau Carriere (vedge@csoft.net)        --
-- Copyright (c) 2010, coreland (mark@coreland.ath.cx)                      --
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
with Ada.Unchecked_Conversion;

package body Agar.DSO is
  use type C.int;

  --
  -- Load a dynamic library file into the current process's address space.
  --
  function Load (Name : in String) return DSO_Access
  is
    Ch_Name : aliased C.char_array := C.To_C (Name);
  begin
    return AG_LoadDSO
      (Name  => CS.To_Chars_Ptr (Ch_Name'Unchecked_Access),
       Flags => 0);
  end Load;

  --
  -- Remove a dynamic library object from the current process's address space.
  --
  function Unload (DSO : DSO_Not_Null_Access) return Boolean
  is begin
    return 1 = AG_UnloadDSO (DSO);
  end Unload;

  --
  -- Return an existing, loaded dynamic library object by name (or null).
  --
  function Lookup (Name : in String) return DSO_Access
  is
    Ch_Name : aliased C.char_array := C.To_C (Name);
  begin
    return AG_LookupDSO (CS.To_Chars_Ptr (Ch_Name'Unchecked_Access));
  end Lookup;
 
  --
  -- Return a list of available dynamically-loaded library files.
  -- Scans the registered module directories for files with matching extensions.
  -- 
  function Get_List return DSO_List
  is
    use type C.unsigned;
    use DSO_List_To_Strings;

    Count  : aliased C.unsigned := 0;
    Result : DSO_List_To_Strings.Pointer := AG_GetDSOList (Count'Access);
    Output : DSO_List;
  begin
    pragma Assert (Result /= null);

    for Index in 1 .. Count loop
      declare
        Element : constant String := CS.Value (Result.all);
      begin
	Output.Append (Element);
      end;
      Increment (Result);
    end loop;

    AG_FreeDSOList
      (List  => Result,
       Count => Count);

    return Output;

  end Get_List;

  --
  -- Resolve the specified symbol in a dynamically-loaded library.
  -- Return a generic pointer to the referenced data.
  -- Returns null if the symbol could not be resolved.
  --
  function Symbol_Lookup
    (DSO    : in DSO_Not_Null_Access;
     Symbol : in String) return Subprogram_Access_Type
  is
    Ch_Symbol : aliased C.char_array := C.To_C (Symbol);
    Result    : aliased System.Address;

    function Convert is new Ada.Unchecked_Conversion
      (Source => System.Address,
       Target => Subprogram_Access_Type);
  begin
    if 1 = AG_SymDSO
      (DSO    => DSO,
       Symbol => CS.To_Chars_Ptr (Ch_Symbol'Unchecked_Access),
       Value  => Result'Unchecked_Access) then
      return Convert (Result);
    else
      return Convert (System.Null_Address);
    end if;
  end Symbol_Lookup;

end Agar.DSO;
