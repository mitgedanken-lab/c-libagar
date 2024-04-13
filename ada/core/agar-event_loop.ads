------------------------------------------------------------------------------
--                            AGAR CORE LIBRARY                             --
--                      A G A R . E V E N T _ L O O P                       --
--                                 S p e c                                  --
------------------------------------------------------------------------------
with System;
with Interfaces.C;
with Interfaces.C.Strings;

--
-- The standard Agar event loop.
--

package Agar.Event_Loop is
  package C renames Interfaces.C;

  --
  -- Run the standard Agar event loop.
  --
  procedure Event_Loop;

  --
  -- Request termination of the event loop.
  --
  procedure Terminate_Event_Loop (Return_Code : in Natural);

  private

  function AG_EventLoop return C.int
    with Import, Convention => C, Link_Name => "AG_EventLoop";

  procedure AG_Terminate
    (Return_Code : in C.int)
    with Import, Convention => C, Link_Name => "AG_Terminate";

end Agar.Event_Loop;
