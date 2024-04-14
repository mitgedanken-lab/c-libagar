#include <agar/core.h>
#include <agar/gui.h>

void ag_lock_drivers(void)   { AG_LockVFS(&agDrivers); }
void ag_unlock_drivers(void) { AG_UnlockVFS(&agDrivers); }
