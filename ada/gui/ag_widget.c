#include <agar/core.h>
#include <agar/gui.h>

/* [Object] -> Driver */
AG_Object *
ag_driver_to_object(AG_Driver *drv)
{
	AG_OBJECT_ISA(drv, "AG_Driver:*");
	return (AG_Object *)drv;
}

/* [Object] -> Widget */
AG_Object *
ag_widget_to_object(AG_Widget *wid)
{
	AG_OBJECT_ISA(wid, "AG_Widget:*");
	return (AG_Object *)wid;
}

/* [Object] -> Widget -> Window */
AG_Object *
ag_window_to_object(AG_Window *win)
{
	AG_OBJECT_ISA(win, "AG_Widget:AG_Window:*");
	return (AG_Object *)win;
}

/* Object -> [Widget] -> Window */
AG_Widget *
ag_window_to_widget(AG_Window *win)
{
	AG_OBJECT_ISA(win, "AG_Widget:AG_Window:*");
	return (AG_Widget *)win;
}

char *
ag_window_get_caption(AG_Window *win)
{
	AG_OBJECT_ISA(win, "AG_Widget:AG_Window:*");
	return (win->caption);
}
