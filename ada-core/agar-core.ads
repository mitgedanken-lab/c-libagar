with interfaces.c;
with interfaces.c.strings;

package agar.core is
  package c renames interfaces.c;
  package cs renames interfaces.c.strings;

  -- version information
  type version_t is record
    major   : c.int;
    minor   : c.int;
    patch   : c.int;
    release : cs.chars_ptr;
  end record;
  type version_access_t is access all version_t;
  pragma convention (c, version_t);
  pragma convention (c, version_access_t);

  -- init flags
  subtype init_flags_t is c.unsigned;

  -- exit callback type
  type exit_callback_t is access procedure;
  pragma convention (c, exit_callback_t);

  -- Flags for init()
  core_verbose : constant init_flags_t := 16#01#;

  procedure get_version (version : version_access_t);
  pragma import (c, get_version, "AG_GetVersion");

  procedure get_version (version : out version_t);
  pragma inline (get_version);

  function init
    (progname : cs.chars_ptr;
     flags    : init_flags_t := 0) return c.int;
  pragma import (c, init, "AG_InitCore");

  function init
    (progname : string;
     flags    : init_flags_t := 0) return boolean;
  pragma inline (init);
 
  procedure at_exit_func (func : exit_callback_t);
  pragma import (c, at_exit_func, "AG_AtExitFunc");

  procedure quit;
  pragma import (c, quit, "AG_Quit");

  procedure destroy;
  pragma import (c, destroy, "AG_Destroy");

end agar.core;