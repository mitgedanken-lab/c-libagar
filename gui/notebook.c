/*
 * Copyright (c) 2005-2007 Hypertriton, Inc. <http://hypertriton.com/>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <core/core.h>
#include <core/view.h>

#include "notebook.h"

#include "window.h"
#include "primitive.h"

static AG_WidgetOps agNotebookOps = {
	{
		"AG_Widget:AG_Notebook",
		sizeof(AG_Notebook),
		{ 0,0 },
		NULL,			/* init */
		NULL,			/* reinit */
		AG_NotebookDestroy,
		NULL,			/* load */
		NULL,			/* save */
		NULL			/* edit */
	},
	AG_NotebookDraw,
	AG_NotebookScale
};

#define SPACING 8

AG_Notebook *
AG_NotebookNew(void *parent, Uint flags)
{
	AG_Notebook *nb;

	nb = Malloc(sizeof(AG_Notebook), M_OBJECT);
	AG_NotebookInit(nb, flags);
	AG_ObjectAttach(parent, nb);
	return (nb);
}

static void
mousebuttondown(AG_Event *event)
{
	AG_Notebook *nb = AG_SELF();
	int button = AG_INT(1);
	int x = AG_INT(2);
	int y = AG_INT(3);

	if ((nb->flags & AG_NOTEBOOK_HIDE_TABS) == 0 &&
	    y <= nb->bar_h) {
		AG_NotebookTab *tab;
		int tx = SPACING;

		TAILQ_FOREACH(tab, &nb->tabs, tabs) {
			SDL_Surface *label = WSURFACE(nb,tab->label);

#if 0
			if (tx+label->w+SPACING*2 > WIDGET(nb)->w)
				break;
#endif
			if (x >= tx && x < tx+(label->w + SPACING*2)) {
				AG_NotebookSelectTab(nb, tab);
				break;
			}
			tx += label->w + SPACING*2;
		}
	}
}

void
AG_NotebookInit(AG_Notebook *nb, Uint flags)
{
	AG_WidgetInit(nb, &agNotebookOps, AG_WIDGET_CLIPPING);

	nb->flags = flags;
	nb->tab_align = AG_NOTEBOOK_TABS_TOP;
	nb->sel_tab = NULL;
	nb->bar_w = -1;
	nb->bar_h = -1;
	nb->cont_w = -1;
	nb->cont_h = -1;
	nb->tab_rad = (int)(agTextFontHeight/1.5);
	nb->spacing = -1;
	nb->padding = -1;
	nb->tabFont = AG_FetchFont(NULL, agDefaultFont->size-2, 0);
	AG_MutexInitRecursive(&nb->lock);
	TAILQ_INIT(&nb->tabs);

	if (flags & AG_NOTEBOOK_HFILL)	WIDGET(nb)->flags |= AG_WIDGET_HFILL;
	if (flags & AG_NOTEBOOK_VFILL)	WIDGET(nb)->flags |= AG_WIDGET_VFILL;

	AG_SetEvent(nb, "window-mousebuttondown", mousebuttondown, NULL);
}

void
AG_NotebookDestroy(void *p)
{
	AG_Notebook *nb = p;

	AG_MutexDestroy(&nb->lock);
	AG_WidgetDestroy(nb);
}

void
AG_NotebookDraw(void *p)
{
	AG_Notebook *nb = p;
	AG_NotebookTab *tab;
	int x = SPACING;
	int y = SPACING;
	SDL_Rect box;

	agPrim.rect_filled(nb,
	    0, nb->bar_h,
	    WIDGET(nb)->w,
	    WIDGET(nb)->h - nb->bar_h,
	    AG_COLOR(NOTEBOOK_SEL_COLOR));

	if (nb->flags & AG_NOTEBOOK_HIDE_TABS) {
		return;
	}
	TAILQ_FOREACH(tab, &nb->tabs, tabs) {
		box.x = x;
		box.y = y;
		box.w = WSURFACE(nb,tab->label)->w + SPACING*2;
		box.h = nb->bar_h - SPACING;

#if 0
		if ((box.x+box.w) - WIDGET(nb)->w > 0) {
			box.w = WIDGET(nb)->w - box.x;
			if (box.w < nb->tab_rad<<1) {
				break;
			}
			agPrim.box_chamfered(nb, &box, 1, nb->tab_rad,
			    AG_COLOR(NOTEBOOK_BG_COLOR));
			AG_WidgetBlitSurface(nb, nb->lblMore, x+SPACING, y+2);
			break;
		}
#endif

		agPrim.box_chamfered(nb, &box,
		    nb->sel_tab==tab ? -1 : 1, nb->tab_rad,
		    nb->sel_tab==tab ?
		    AG_COLOR(NOTEBOOK_SEL_COLOR) :
		    AG_COLOR(NOTEBOOK_BG_COLOR));
		
		AG_WidgetBlitSurface(nb, tab->label, x+SPACING, y+2);
		x += box.w;
	}
}

void
AG_NotebookScale(void *p, int w, int h)
{
	AG_Notebook *nb = p;
	AG_NotebookTab *tab;
	
	AG_MutexLock(&nb->lock);
	if (w == -1 || h == -1) {
		if ((nb->flags & AG_NOTEBOOK_HIDE_TABS) == 0) {
			nb->bar_h = agTextFontHeight + SPACING*2;
			nb->bar_w = SPACING*2;
		} else {
			nb->bar_h = 0;
			nb->bar_w = 0;
		}
		nb->cont_w = 0;
		nb->cont_h = 0;
		TAILQ_FOREACH(tab, &nb->tabs, tabs) {
			WIDGET_OPS(tab)->scale(tab, -1, -1);
			nb->cont_w = MAX(nb->cont_w,WIDGET(tab)->w);
			nb->cont_h = MAX(nb->cont_h,WIDGET(tab)->h);
			if ((nb->flags & AG_NOTEBOOK_HIDE_TABS) == 0)
				nb->bar_w += WSURFACE(nb,tab->label)->w +
				    SPACING*2;
		}
		WIDGET(nb)->h = nb->cont_h + nb->bar_h;
		WIDGET(nb)->w = MAX(nb->cont_w, nb->bar_w);
	}
	if ((tab = nb->sel_tab) != NULL) {
		WIDGET(tab)->x = 0;
		WIDGET(tab)->y = nb->bar_h;
		if (nb->flags & AG_NOTEBOOK_HFILL) nb->cont_w = WIDGET(nb)->w;
		if (nb->flags & AG_NOTEBOOK_VFILL) nb->cont_h = WIDGET(nb)->h;
		WIDGET(tab)->w = nb->cont_w;
		WIDGET(tab)->h = nb->cont_h - nb->bar_h;
		WIDGET_OPS(tab)->scale(tab,
		    WIDGET(tab)->w,
		    WIDGET(tab)->h);
	}
	AG_MutexUnlock(&nb->lock);
}

void
AG_NotebookSetTabAlignment(AG_Notebook *nb, enum ag_notebook_tab_alignment ta)
{
	AG_MutexLock(&nb->lock);
	nb->tab_align = ta;
	AG_MutexUnlock(&nb->lock);
}

void
AG_NotebookSetSpacing(AG_Notebook *nb, int spacing)
{
	AG_MutexLock(&nb->lock);
	nb->spacing = spacing;
	AG_MutexUnlock(&nb->lock);
}

void
AG_NotebookSetTabFont(AG_Notebook *nb, AG_Font *font)
{
	AG_MutexLock(&nb->lock);
	nb->tabFont = font;
	AG_MutexUnlock(&nb->lock);
}

void
AG_NotebookSetPadding(AG_Notebook *nb, int padding)
{
	AG_MutexLock(&nb->lock);
	nb->padding = padding;
	AG_MutexUnlock(&nb->lock);
}

AG_NotebookTab *
AG_NotebookAddTab(AG_Notebook *nb, const char *label, enum ag_box_type btype)
{
	AG_NotebookTab *tab;

	tab = Malloc(sizeof(AG_NotebookTab), M_OBJECT);
	AG_BoxInit((AG_Box *)tab, btype, AG_BOX_HFILL|AG_BOX_VFILL);
	if (nb->padding >= 0)
		AG_BoxSetPadding((AG_Box *)tab, nb->padding);
	if (nb->spacing >= 0)
		AG_BoxSetSpacing((AG_Box *)tab, nb->spacing);

	AG_TextFont(nb->tabFont);
	AG_TextColor(NOTEBOOK_TXT_COLOR);
	tab->label = AG_WidgetMapSurface(nb, AG_TextRender(label));
	TAILQ_INSERT_TAIL(&nb->tabs, tab, tabs);
	if (TAILQ_FIRST(&nb->tabs) == tab) {
		AG_NotebookSelectTab(nb, tab);
	}
	return (tab);
}

void
AG_NotebookDelTab(AG_Notebook *nb, AG_NotebookTab *tab)
{
	TAILQ_REMOVE(&nb->tabs, tab, tabs);
	AG_WidgetUnmapSurface(nb, tab->label);
	AG_ObjectDestroy(tab);
	Free(tab, M_OBJECT);
}

void
AG_NotebookSelectTab(AG_Notebook *nb, AG_NotebookTab *tab)
{
	AG_Window *pwin = AG_WidgetParentWindow(nb);

#ifdef DEBUG
	if (pwin == NULL)
		fatal("no window is attached");
#endif
	if (nb->sel_tab != NULL) {
		AG_ObjectDetach(nb->sel_tab);
	}
	if (tab == NULL) {
		nb->sel_tab = NULL;
		return;
	}
	AG_ObjectAttach(nb, tab);
	nb->sel_tab = tab;

	WIDGET_OPS(tab)->scale(tab, -1, -1);
	WIDGET_OPS(tab)->scale(tab, WIDGET(tab)->w, WIDGET(tab)->h);
	AG_NotebookScale(nb, WIDGET(nb)->w, WIDGET(nb)->h);
	AG_WidgetUpdateCoords(pwin, WIDGET(pwin)->x, WIDGET(pwin)->y);
#if 0
	AG_WidgetFocus(tab);
#endif
}

void
AG_NotebookSetTabVisibility(AG_Notebook *nb, int flag)
{
	if (flag) {
		nb->flags &= ~(AG_NOTEBOOK_HIDE_TABS);
	} else {
		nb->flags |= AG_NOTEBOOK_HIDE_TABS;
	}
}
