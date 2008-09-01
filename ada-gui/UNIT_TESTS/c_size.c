#include <agar/core.h>
#include <agar/gui.h>

#include <stdio.h>
#include <string.h>

struct {
  const char *type_name;
  unsigned int type_size;
} types[] = {
  /* auto generated - do not edit */
  { "AG_BlendFn", sizeof (AG_BlendFn) },
  { "enum ag_blend_func", sizeof (enum ag_blend_func) },
  { "AG_Color", sizeof (AG_Color) },
  { "struct ag_color", sizeof (struct ag_color) },
  { "AG_PixelFormat *", sizeof (AG_PixelFormat *) },
  { "AG_PixelFormat", sizeof (AG_PixelFormat) },
  { "AG_Point", sizeof (AG_Point) },
  { "struct ag_point", sizeof (struct ag_point) },
  { "AG_Rect *", sizeof (AG_Rect *) },
  { "struct ag_rect *", sizeof (struct ag_rect *) },
  { "AG_Rect", sizeof (AG_Rect) },
  { "struct ag_rect", sizeof (struct ag_rect) },
  { "AG_Style *", sizeof (AG_Style *) },
  { "struct ag_style *", sizeof (struct ag_style *) },
  { "AG_Style", sizeof (AG_Style) },
  { "struct ag_style", sizeof (struct ag_style) },
  { "AG_Surface *", sizeof (AG_Surface *) },
  { "AG_Surface", sizeof (AG_Surface) },
  { "AG_Font *", sizeof (AG_Font *) },
  { "struct ag_font *", sizeof (struct ag_font *) },
  { "AG_Font", sizeof (AG_Font) },
  { "struct ag_font", sizeof (struct ag_font) },
  { "enum ag_font_type", sizeof (enum ag_font_type) },
  { "AG_Glyph *", sizeof (AG_Glyph *) },
  { "struct ag_glyph *", sizeof (struct ag_glyph *) },
  { "AG_Glyph", sizeof (AG_Glyph) },
  { "struct ag_glyph", sizeof (struct ag_glyph) },
  { "enum ag_text_justify", sizeof (enum ag_text_justify) },
  { "AG_TextMetrics *", sizeof (AG_TextMetrics *) },
  { "struct ag_text_metrics *", sizeof (struct ag_text_metrics *) },
  { "AG_TextMetrics", sizeof (AG_TextMetrics) },
  { "struct ag_text_metrics", sizeof (struct ag_text_metrics) },
  { "enum ag_text_msg_title", sizeof (enum ag_text_msg_title) },
  { "AG_TextState *", sizeof (AG_TextState *) },
  { "struct ag_text_state *", sizeof (struct ag_text_state *) },
  { "AG_TextState", sizeof (AG_TextState) },
  { "struct ag_text_state", sizeof (struct ag_text_state) },
  { "AG_StaticFont *", sizeof (AG_StaticFont *) },
  { "struct ag_static_font *", sizeof (struct ag_static_font *) },
  { "AG_StaticFont", sizeof (AG_StaticFont) },
  { "struct ag_static_font", sizeof (struct ag_static_font) },
  { "enum ag_text_valign", sizeof (enum ag_text_valign) },
  { "AG_Unit", sizeof (AG_Unit) },
  { "struct ag_unit", sizeof (struct ag_unit) },
  { "AG_Display", sizeof (AG_Display) },
  { "struct ag_display", sizeof (struct ag_display) },
  { "AG_WidgetBinding *", sizeof (AG_WidgetBinding *) },
  { "struct ag_widget_binding *", sizeof (struct ag_widget_binding *) },
  { "AG_WidgetBinding", sizeof (AG_WidgetBinding) },
  { "struct ag_widget_binding", sizeof (struct ag_widget_binding) },
  { "AG_WidgetBindingType", sizeof (AG_WidgetBindingType) },
  { "enum ag_widget_binding_type", sizeof (enum ag_widget_binding_type) },
  { "AG_Box *", sizeof (AG_Box *) },
  { "struct ag_box *", sizeof (struct ag_box *) },
  { "AG_Box", sizeof (AG_Box) },
  { "struct ag_box", sizeof (struct ag_box) },
  { "enum ag_box_type", sizeof (enum ag_box_type) },
  { "AG_Button *", sizeof (AG_Button *) },
  { "struct ag_button *", sizeof (struct ag_button *) },
  { "AG_Button", sizeof (AG_Button) },
  { "struct ag_button", sizeof (struct ag_button) },
  { "AG_Checkbox *", sizeof (AG_Checkbox *) },
  { "struct ag_checkbox *", sizeof (struct ag_checkbox *) },
  { "AG_Checkbox", sizeof (AG_Checkbox) },
  { "struct ag_checkbox", sizeof (struct ag_checkbox) },
  { "AG_WidgetClass *", sizeof (AG_WidgetClass *) },
  { "struct ag_widget_class *", sizeof (struct ag_widget_class *) },
  { "AG_WidgetClass", sizeof (AG_WidgetClass) },
  { "struct ag_widget_class", sizeof (struct ag_widget_class) },
  { "AG_Combo *", sizeof (AG_Combo *) },
  { "struct ag_combo *", sizeof (struct ag_combo *) },
  { "AG_Combo", sizeof (AG_Combo) },
  { "struct ag_combo", sizeof (struct ag_combo) },
  { "AG_Console *", sizeof (AG_Console *) },
  { "struct ag_console *", sizeof (struct ag_console *) },
  { "AG_Console", sizeof (AG_Console) },
  { "struct ag_console", sizeof (struct ag_console) },
  { "AG_ConsoleLine *", sizeof (AG_ConsoleLine *) },
  { "struct ag_console_line *", sizeof (struct ag_console_line *) },
  { "AG_ConsoleLine", sizeof (AG_ConsoleLine) },
  { "struct ag_console_line", sizeof (struct ag_console_line) },
  { "AG_Editable *", sizeof (AG_Editable *) },
  { "struct ag_editable *", sizeof (struct ag_editable *) },
  { "AG_Editable", sizeof (AG_Editable) },
  { "struct ag_editable", sizeof (struct ag_editable) },
  { "enum ag_editable_encoding", sizeof (enum ag_editable_encoding) },
  { "AG_FileDlg *", sizeof (AG_FileDlg *) },
  { "struct ag_file_dlg *", sizeof (struct ag_file_dlg *) },
  { "AG_FileDlg", sizeof (AG_FileDlg) },
  { "struct ag_file_dlg", sizeof (struct ag_file_dlg) },
  { "AG_FileType *", sizeof (AG_FileType *) },
  { "struct ag_file_type *", sizeof (struct ag_file_type *) },
  { "AG_FileType", sizeof (AG_FileType) },
  { "struct ag_file_type", sizeof (struct ag_file_type) },
  { "AG_FileOption *", sizeof (AG_FileOption *) },
  { "struct ag_file_type_option *", sizeof (struct ag_file_type_option *) },
  { "AG_FileOption", sizeof (AG_FileOption) },
  { "struct ag_file_type_option", sizeof (struct ag_file_type_option) },
  { "enum ag_file_type_option_type", sizeof (enum ag_file_type_option_type) },
  { "AG_FlagDescr *", sizeof (AG_FlagDescr *) },
  { "struct ag_flag_descr *", sizeof (struct ag_flag_descr *) },
  { "AG_FlagDescr", sizeof (AG_FlagDescr) },
  { "struct ag_flag_descr", sizeof (struct ag_flag_descr) },
  { "AG_LabelFormatFn", sizeof (AG_LabelFormatFn) },
  { "struct ag_label_flag", sizeof (struct ag_label_flag) },
  { "AG_LabelFormatSpec *", sizeof (AG_LabelFormatSpec *) },
  { "struct ag_label_format_spec *", sizeof (struct ag_label_format_spec *) },
  { "AG_LabelFormatSpec", sizeof (AG_LabelFormatSpec) },
  { "struct ag_label_format_spec", sizeof (struct ag_label_format_spec) },
  { "AG_Label *", sizeof (AG_Label *) },
  { "struct ag_label *", sizeof (struct ag_label *) },
  { "AG_Label", sizeof (AG_Label) },
  { "struct ag_label", sizeof (struct ag_label) },
  { "enum ag_label_type", sizeof (enum ag_label_type) },
  { "enum ag_menu_binding", sizeof (enum ag_menu_binding) },
  { "AG_MenuItem *", sizeof (AG_MenuItem *) },
  { "struct ag_menu_item *", sizeof (struct ag_menu_item *) },
  { "AG_MenuItem", sizeof (AG_MenuItem) },
  { "struct ag_menu_item", sizeof (struct ag_menu_item) },
  { "AG_Menu *", sizeof (AG_Menu *) },
  { "struct ag_menu *", sizeof (struct ag_menu *) },
  { "AG_Menu", sizeof (AG_Menu) },
  { "struct ag_menu", sizeof (struct ag_menu) },
  { "AG_MenuView *", sizeof (AG_MenuView *) },
  { "struct ag_menu_view *", sizeof (struct ag_menu_view *) },
  { "AG_MenuView", sizeof (AG_MenuView) },
  { "struct ag_menu_view", sizeof (struct ag_menu_view) },
  { "AG_Pane *", sizeof (AG_Pane *) },
  { "struct ag_pane *", sizeof (struct ag_pane *) },
  { "AG_Pane", sizeof (AG_Pane) },
  { "struct ag_pane", sizeof (struct ag_pane) },
  { "enum ag_pane_type", sizeof (enum ag_pane_type) },
  { "enum ag_scrollbar_button", sizeof (enum ag_scrollbar_button) },
  { "AG_Scrollbar *", sizeof (AG_Scrollbar *) },
  { "struct ag_scrollbar *", sizeof (struct ag_scrollbar *) },
  { "AG_Scrollbar", sizeof (AG_Scrollbar) },
  { "struct ag_scrollbar", sizeof (struct ag_scrollbar) },
  { "enum ag_scrollbar_type", sizeof (enum ag_scrollbar_type) },
  { "AG_SizeReq *", sizeof (AG_SizeReq *) },
  { "struct ag_size_req *", sizeof (struct ag_size_req *) },
  { "AG_SizeReq", sizeof (AG_SizeReq) },
  { "struct ag_size_req", sizeof (struct ag_size_req) },
  { "enum ag_widget_sizespec", sizeof (enum ag_widget_sizespec) },
  { "AG_Textbox *", sizeof (AG_Textbox *) },
  { "struct ag_textbox *", sizeof (struct ag_textbox *) },
  { "AG_Textbox", sizeof (AG_Textbox) },
  { "struct ag_textbox", sizeof (struct ag_textbox) },
  { "AG_TlistItem *", sizeof (AG_TlistItem *) },
  { "struct ag_tlist_item *", sizeof (struct ag_tlist_item *) },
  { "AG_TlistItem", sizeof (AG_TlistItem) },
  { "struct ag_tlist_item", sizeof (struct ag_tlist_item) },
  { "AG_TlistPopup *", sizeof (AG_TlistPopup *) },
  { "struct ag_tlist_popup *", sizeof (struct ag_tlist_popup *) },
  { "AG_TlistPopup", sizeof (AG_TlistPopup) },
  { "struct ag_tlist_popup", sizeof (struct ag_tlist_popup) },
  { "AG_Tlist *", sizeof (AG_Tlist *) },
  { "struct ag_tlist *", sizeof (struct ag_tlist *) },
  { "AG_Tlist", sizeof (AG_Tlist) },
  { "struct ag_tlist", sizeof (struct ag_tlist) },
  { "AG_Toolbar *", sizeof (AG_Toolbar *) },
  { "struct ag_toolbar *", sizeof (struct ag_toolbar *) },
  { "AG_Toolbar", sizeof (AG_Toolbar) },
  { "struct ag_toolbar", sizeof (struct ag_toolbar) },
  { "enum ag_toolbar_type", sizeof (enum ag_toolbar_type) },
  { "AG_Widget *", sizeof (AG_Widget *) },
  { "struct ag_widget *", sizeof (struct ag_widget *) },
  { "AG_Widget", sizeof (AG_Widget) },
  { "struct ag_widget", sizeof (struct ag_widget) },
  { "enum ag_window_alignment", sizeof (enum ag_window_alignment) },
  { "enum ag_window_close_action", sizeof (enum ag_window_close_action) },
  { "AG_Window *", sizeof (AG_Window *) },
  { "struct ag_window *", sizeof (struct ag_window *) },
  { "AG_Window", sizeof (AG_Window) },
  { "struct ag_window", sizeof (struct ag_window) },
};
const unsigned int types_size = sizeof (types) / sizeof (types[0]);

void
find (const char *name)
{
  unsigned int pos;
  for (pos = 0; pos < types_size; ++pos) {
    if (strcmp (types[pos].type_name, name) == 0) {
      printf ("%u\n", types[pos].type_size * 8);
      return;
    }
  }
  fprintf (stderr, "fatal: unknown C type\n");
  exit (112);
}

int
main (int argc, char *argv[])
{
  if (argc != 2) exit (111);
  find (argv[1]);
  return 0;
}
