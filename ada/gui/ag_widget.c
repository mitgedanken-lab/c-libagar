#include <agar/core.h>
#include <agar/gui.h>

AG_Object *ag_driver_to_object(AG_Driver *p) { AG_OBJECT_ISA(p, "AG_Driver:*"); return (AG_Object *)p; }
AG_Object *ag_widget_to_object(AG_Widget *p) { AG_OBJECT_ISA(p, "AG_Widget:*"); return (AG_Object *)p; }
AG_Widget *ag_window_to_widget(AG_Window *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Window:*"); return (AG_Widget *)p; }
AG_Object *ag_window_to_object(AG_Window *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Window:*"); return (AG_Object *)p; }

AG_Widget *ag_box_to_widget(AG_Box *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Box:*"); return (AG_Widget *)p; }
AG_Object *ag_box_to_object(AG_Box *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Box:*"); return (AG_Object *)p; }

AG_Widget *ag_button_to_widget(AG_Button *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Button:*"); return (AG_Widget *)p; }
AG_Object *ag_button_to_object(AG_Button *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Button:*"); return (AG_Object *)p; }

AG_Widget *ag_checkbox_to_widget(AG_Checkbox *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Checkbox:*"); return (AG_Widget *)p; }
AG_Object *ag_checkbox_to_object(AG_Checkbox *p) { AG_OBJECT_ISA(p, "AG_Widget:AG_Checkbox:*"); return (AG_Object *)p; }

char *
ag_window_get_caption(AG_Window *win)
{
	AG_OBJECT_ISA(win, "AG_Widget:AG_Window:*");
	return (win->caption);
}
