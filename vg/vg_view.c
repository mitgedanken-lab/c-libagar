/*
 * Copyright (c) 2005-2008 Hypertriton, Inc. <http://hypertriton.com/>
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

/*
 * Visualization widget.
 */

#include <core/core.h>
#include <core/config.h>

#include <stdarg.h>
#include <string.h>

#include <gui/view.h>
#include <gui/window.h>
#include <gui/primitive.h>
#include <gui/opengl.h>

#include "vg.h"
#include "vg_view.h"

VG_View *
VG_ViewNew(void *parent, VG *vg, Uint flags)
{
	VG_View *vv;

	vv = Malloc(sizeof(VG_View));
	AG_ObjectInit(vv, &vgViewClass);
	vv->flags |= flags;
	vv->vg = vg;
	
	if (flags & VG_VIEW_HFILL) { AG_ExpandHoriz(vv); }
	if (flags & VG_VIEW_VFILL) { AG_ExpandVert(vv); }

	AG_ObjectAttach(parent, vv);
	return (vv);
}

static void
MouseMotion(AG_Event *event)
{
	VG_View *vv = AG_SELF();
	VG_Tool *tool = VG_CURTOOL(vv);
	int xCurs = AG_INT(1);
	int yCurs = AG_INT(2);
	float xRel = (float)AG_INT(3);
	float yRel = (float)AG_INT(4);
	int state = AG_INT(5);
	float x, y;
	VG_Vector vCt;

	if (vv->mouse.panning) {
		vv->x += (float)xRel;
		vv->y += (float)yRel;
		return;
	}

	VG_GetVGCoords(vv, xCurs,yCurs, &vCt);
	x = vCt.x;
	y = vCt.y;

	if (tool != NULL && tool->ops->mousemotion != NULL) {
		if (!(tool->ops->flags & VG_MOUSEMOTION_NOSNAP)) {
			VG_ApplyConstraints(vv, &vCt);
		}
		tool->vCursor = vCt;
		if (tool->ops->mousemotion(tool, vCt,
		    VG_ScaleVector(1.0f/vv->scale,VGVECTOR(xRel,yRel)),
		    state) == 1) {
			vv->mouse.x = x;
			vv->mouse.y = y;
			return;
		}
	} else {
		vv->mouse.x = x;
		vv->mouse.y = y;
	}
}

static void
MouseButtonDown(AG_Event *event)
{
	VG_View *vv = AG_SELF();
	VG_Tool *tool = VG_CURTOOL(vv);
	int button = AG_INT(1);
	int xCurs = AG_INT(2);
	int yCurs = AG_INT(3);
	VG_ToolMouseBinding *mb;
	float x, y;
	VG_Vector vCt;

	VG_GetVGCoords(vv, xCurs,yCurs, &vCt);
	x = vCt.x;
	y = vCt.y;

	AG_WidgetFocus(vv);
	vv->mouse.x = x;
	vv->mouse.y = y;
	switch (button) {
	case SDL_BUTTON_MIDDLE:
		vv->mouse.panning = 1;
		break;
	case SDL_BUTTON_WHEELDOWN:
		VG_ViewSetScale(vv, vv->scale-2.0f);
		return;
	case SDL_BUTTON_WHEELUP:
		VG_ViewSetScale(vv, vv->scale+2.0f);
		return;
	default:
		break;
	}
	if (tool != NULL && tool->ops->mousebuttondown != NULL) {
		if (!(tool->ops->flags & VG_BUTTONDOWN_NOSNAP)) {
			VG_ApplyConstraints(vv, &vCt);
		}
		if (tool->ops->mousebuttondown(tool, vCt, button) == 1)
			return;
	}
	TAILQ_FOREACH(tool, &vv->tools, tools) {
		SLIST_FOREACH(mb, &tool->mbindings, mbindings) {
			if (mb->button != button) {
				continue;
			}
			tool->vgv = vv;
			if (mb->func(tool, button, 1, x, y, mb->arg) == 1)
				return;
		}
	}
	if (vv->btndown_ev != NULL)
		AG_PostEvent(NULL, vv, vv->btndown_ev->name,
		    "%i,%f,%f", button, x, y);
}

static void
MouseButtonUp(AG_Event *event)
{
	VG_View *vv = AG_SELF();
	VG_Tool *tool = VG_CURTOOL(vv);
	int button = AG_INT(1);
	int xCurs = AG_INT(2);
	int yCurs = AG_INT(3);
	VG_ToolMouseBinding *mb;
	float x, y;
	VG_Vector vCt;
	
	VG_GetVGCoords(vv, xCurs,yCurs, &vCt);
	x = vCt.x;
	y = vCt.y;

	if (tool != NULL && tool->ops->mousebuttonup != NULL) {
		if (!(tool->ops->flags & VG_BUTTONUP_NOSNAP)) {
			VG_ApplyConstraints(vv, &vCt);
		}
		if (tool->ops->mousebuttonup(tool, vCt, button) == 1)
			return;
	}
	TAILQ_FOREACH(tool, &vv->tools, tools) {
		SLIST_FOREACH(mb, &tool->mbindings, mbindings) {
			if (mb->button != button) {
				continue;
			}
			tool->vgv = vv;
			if (mb->func(tool, button, 0, x, y, mb->arg) == 1)
				return;
		}
	}
	switch (button) {
	case SDL_BUTTON_MIDDLE:
		vv->mouse.panning = 0;
		return;
	default:
		break;
	}
	if (vv->btnup_ev != NULL)
		AG_PostEvent(NULL, vv, vv->btnup_ev->name, "%i,%f,%f",
		    button, x, y);
}

static void
KeyDown(AG_Event *event)
{
	VG_View *vv = AG_SELF();
	VG_Tool *tool = VG_CURTOOL(vv);
	int keysym = AG_INT(1);
	int keymod = AG_INT(2);
	int unicode = AG_INT(3);
	
	if (tool != NULL && tool->ops->keydown != NULL) {
		if (tool->ops->keydown(tool, keysym, keymod, unicode) == 1)
			return;
	}
	/* TODO panning, etc... */
}

static void
KeyUp(AG_Event *event)
{
	VG_View *vv = AG_SELF();
	VG_Tool *tool = VG_CURTOOL(vv);
	int keysym = AG_INT(1);
	int keymod = AG_INT(2);
	int unicode = AG_INT(3);
	
	if (tool != NULL && tool->ops->keyup != NULL) {
		if (tool->ops->keyup(tool, keysym, keymod, unicode) == 1)
			return;
	}
	/* TODO panning, etc... */
}

static void
OnShow(AG_Event *event)
{
	VG_View *vv = AG_SELF();

	vv->x = AGWIDGET(vv)->w/2.0f;
	vv->y = AGWIDGET(vv)->h/2.0f;
}

static void
Init(void *obj)
{
	VG_View *vv = obj;

	WIDGET(vv)->flags |= AG_WIDGET_FOCUSABLE|AG_WIDGET_CLIPPING;

	vv->flags = VG_VIEW_BGFILL;
	vv->vg = NULL;
	vv->draw_ev = NULL;
	vv->scale_ev = NULL;
	vv->keydown_ev = NULL;
	vv->btndown_ev = NULL;
	vv->keyup_ev = NULL;
	vv->btnup_ev = NULL;
	vv->motion_ev = NULL;
	vv->x = 0.0f;
	vv->y = 0.0f;
	vv->scale = 1.0f;
	vv->scaleMin = 1e-6f;
	vv->scaleMax = 1e6f;
	vv->wPixel = 1.0f;
	vv->snap_mode = VG_GRID;
	vv->ortho_mode = VG_NO_ORTHO;
	vv->gridIval = 4.0f;
	vv->mouse.x = 0.0f;
	vv->mouse.y = 0.0f;
	vv->mouse.panning = 0;
	vv->curtool = NULL;
	vv->deftool = NULL;
	vv->status[0] = '\0';
	vv->tCache = AG_TextCacheNew(vv, 128, 16);
	TAILQ_INIT(&vv->tools);

	AG_SetEvent(vv, "window-mousemotion", MouseMotion, NULL);
	AG_SetEvent(vv, "window-mousebuttondown", MouseButtonDown, NULL);
	AG_SetEvent(vv, "window-mousebuttonup", MouseButtonUp, NULL);
	AG_SetEvent(vv, "window-keydown", KeyDown, NULL);
	AG_SetEvent(vv, "window-keyup", KeyUp, NULL);
	AG_SetEvent(vv, "widget-shown", OnShow, NULL);
}

static void
Destroy(void *obj)
{
	VG_View *vv = obj;

	if (vv->tCache != NULL)
		AG_TextCacheDestroy(vv->tCache);
}

void
VG_ViewSetSnapMode(VG_View *vv, enum vg_snap_mode mode)
{
	AG_ObjectLock(vv);
	vv->snap_mode = mode;
	AG_ObjectUnlock(vv);
}

void
VG_ViewSetOrthoMode(VG_View *vv, enum vg_ortho_mode mode)
{
	AG_ObjectLock(vv);
	vv->ortho_mode = mode;
	AG_ObjectUnlock(vv);
}

void
VG_ViewSetGridInterval(VG_View *vv, float ival)
{
	AG_ObjectLock(vv);
	vv->gridIval = ival;
	AG_ObjectUnlock(vv);
}

void
VG_ViewDrawFn(VG_View *vv, AG_EventFn fn, const char *fmt, ...)
{
	AG_ObjectLock(vv);
	vv->draw_ev = AG_SetEvent(vv, NULL, fn, NULL);
	AG_EVENT_GET_ARGS(vv->draw_ev, fmt);
	AG_ObjectUnlock(vv);
}

void
VG_ViewScaleFn(VG_View *vv, AG_EventFn fn, const char *fmt, ...)
{
	AG_ObjectLock(vv);
	vv->scale_ev = AG_SetEvent(vv, NULL, fn, NULL);
	AG_EVENT_GET_ARGS(vv->scale_ev, fmt);
	AG_ObjectUnlock(vv);
}

void
VG_ViewKeydownFn(VG_View *vv, AG_EventFn fn, const char *fmt, ...)
{
	AG_ObjectLock(vv);
	vv->keydown_ev = AG_SetEvent(vv, "window-keydown", fn, NULL);
	AG_EVENT_GET_ARGS(vv->keydown_ev, fmt);
	AG_ObjectUnlock(vv);
}

void
VG_ViewKeyupFn(VG_View *vv, AG_EventFn fn, const char *fmt, ...)
{
	AG_ObjectLock(vv);
	vv->keyup_ev = AG_SetEvent(vv, "window-keyup", fn, NULL);
	AG_EVENT_GET_ARGS(vv->keyup_ev, fmt);
	AG_ObjectUnlock(vv);
}

void
VG_ViewButtondownFn(VG_View *vv, AG_EventFn fn, const char *fmt, ...)
{
	AG_ObjectLock(vv);
	vv->btndown_ev = AG_SetEvent(vv, NULL, fn, NULL);
	AG_EVENT_GET_ARGS(vv->btndown_ev, fmt);
	AG_ObjectUnlock(vv);
}

void
VG_ViewButtonupFn(VG_View *vv, AG_EventFn fn, const char *fmt, ...)
{
	AG_ObjectLock(vv);
	vv->btnup_ev = AG_SetEvent(vv, "window-mousebuttonup", fn, NULL);
	AG_EVENT_GET_ARGS(vv->btnup_ev, fmt);
	AG_ObjectUnlock(vv);
}

void
VG_ViewMotionFn(VG_View *vv, AG_EventFn fn, const char *fmt, ...)
{
	AG_ObjectLock(vv);
	vv->motion_ev = AG_SetEvent(vv, "window-mousemotion", fn, NULL);
	AG_EVENT_GET_ARGS(vv->motion_ev, fmt);
	AG_ObjectUnlock(vv);
}

static void
SizeRequest(void *p, AG_SizeReq *r)
{
	r->w = 16;
	r->h = 16;
}

static int
SizeAllocate(void *p, const AG_SizeAlloc *a)
{
	if (a->w < 16 || a->h < 16) {
		return (-1);
	}
	return (0);
}

static __inline__ void
DrawGrid(VG_View *vv)
{
	int x, x0, y, ival;
	Uint32 c32;

	if ((ival = (int)(vv->gridIval*vv->scale)) < 5) {
		return;
	}
#ifdef HAVE_OPENGL
	if (agView->opengl) {
		x0 = WIDGET(vv)->cx + (int)(vv->x)%ival;
		y = WIDGET(vv)->cy + (int)(vv->y)%ival;
		glBegin(GL_POINTS);
		glColor3ub(vv->vg->gridColor.r, vv->vg->gridColor.g,
		           vv->vg->gridColor.b);
		for (; y < WIDGET(vv)->cy2; y += ival) {
			for (x = x0; x < WIDGET(vv)->cx2; x += ival)
				glVertex2s(x, y);
		}
		glEnd();
	} else
#endif
	{
		x0 = (int)(vv->x)%ival;
		y = (int)(vv->y)%ival;
		c32 = VG_MapColorRGB(vv->vg->gridColor);
		for (; y < WIDGET(vv)->cy2; y += ival) {
			for (x = x0; x < WIDGET(vv)->cx2; x += ival)
				AG_DrawPixel(vv, x, y, c32);
		}
	}
}

#ifdef DEBUG
static void
DrawNodeExtent(VG_Node *vn, VG_View *vv)
{
	VG_Rect vExt;
	AG_Rect rExt;
	VG_Vector v;

	if (vn->ops->extent == NULL) {
		return;
	}
	vn->ops->extent(vn, vv, &vExt);
	v.x = vExt.x;
	v.y = vExt.y;
	VG_GetViewCoords(vv, v, &rExt.x, &rExt.y);
	rExt.w = (int)(vExt.w*vv->scale);
	rExt.h = (int)(vExt.h*vv->scale);
	AG_DrawRectOutline(vv, rExt, AG_MapRGB(agVideoFmt, 250,0,0));
}
#endif /* DEBUG */

static void
DrawNode(VG *vg, VG_Node *vn, VG_View *vv)
{
	VG_Node *vnChld;
	VG_Color colorSave;

	VG_PushMatrix(vg);
	VG_MultMatrix(&vg->T[vg->nT-1], &vn->T);

	VG_FOREACH_CHLD(vnChld, vn, vg_node)
		DrawNode(vg, vnChld, vv);
#ifdef DEBUG
	if (vv->flags & VG_VIEW_EXTENTS)
		DrawNodeExtent(vn, vv);
#endif
	colorSave = vn->color;
	if (vn->flags & VG_NODE_SELECTED) {
		VG_BlendColors(&vn->color, vg->selectionColor);
	}
	if (vn->flags & VG_NODE_MOUSEOVER) {
		VG_BlendColors(&vn->color, vg->mouseoverColor);
	}
	vn->ops->draw(vn, vv);
	vn->color = colorSave;

	VG_PopMatrix(vg);
}

static void
Draw(void *p)
{
	VG_View *vv = p;
	VG *vg = vv->vg;
	int su;

	if (vv->flags & VG_VIEW_BGFILL) {
		AG_DrawRectFilled(vv, AG_RECT(0,0,WIDTH(vv),HEIGHT(vv)),
		    VG_MapColorRGB(vg->fillColor));
	} 
	if (vv->flags & VG_VIEW_GRID)
		DrawGrid(vv);

	VG_Lock(vg);

	if (vv->curtool != NULL && vv->curtool->ops->predraw != NULL)
		vv->curtool->ops->predraw(vv->curtool, vv);
	if (vv->draw_ev != NULL)
		vv->draw_ev->handler(vv->draw_ev);
	if (vv->curtool != NULL && vv->curtool->ops->postdraw != NULL)
		vv->curtool->ops->postdraw(vv->curtool, vv);

	DrawNode(vg, vg->root, vv);
	VG_Unlock(vg);

	AG_TextColor(TEXT_COLOR);
	su = AG_TextCacheInsLookup(vv->tCache, vv->status);
	AG_WidgetBlitSurface(vv, su, 0, HEIGHT(vv)-WSURFACE(vv,su)->h);
}

void
VG_ViewSelectTool(VG_View *vv, VG_Tool *ntool, void *p)
{
	AG_ObjectLock(vv);
	if (vv->curtool != NULL) {
		if (vv->curtool->trigger != NULL) {
			AG_WidgetSetBool(vv->curtool->trigger, "state", 0);
		}
		if (vv->curtool->win != NULL) {
			AG_WindowHide(vv->curtool->win);
		}
		if (vv->curtool->pane != NULL) {
			AG_Widget *wt;
			AG_Window *pwin;

			OBJECT_FOREACH_CHILD(wt, vv->curtool->pane, ag_widget) {
				AG_ObjectDetach(wt);
				AG_ObjectDestroy(wt);
			}
			if ((pwin = AG_WidgetParentWindow(vv->curtool->pane))
			    != NULL) {
				AG_WindowUpdate(pwin);
			}
		}
		vv->curtool->vgv = NULL;
	}
	vv->curtool = ntool;

	if (ntool != NULL) {
		ntool->p = p;
		ntool->vgv = vv;

		if (ntool->trigger != NULL) {
			AG_WidgetSetBool(ntool->trigger, "state", 1);
		}
		if (ntool->win != NULL) {
			AG_WindowShow(ntool->win);
		}
#if 0
		if (ntool->pane != NULL && ntool->ops->edit != NULL) {
			AG_Window *pwin;

			ntool->ops->edit(ntool, ntool->pane);
			if ((pwin = AG_WidgetParentWindow(vv->curtool->pane))
			    != NULL) {
				AG_WindowUpdate(pwin);
			}
		}
#endif
		VG_Status(vv, _("Tool: %s"), ntool->ops->name);
	} else {
		VG_Status(vv, NULL);
	}
#if 0
	if ((pwin = AG_WidgetParentWindow(vv)) != NULL) {
		agView->winToFocus = pwin;
		AG_WidgetFocus(vv);
	}
#endif
	AG_ObjectUnlock(vv);
}

void
VG_ViewSelectToolEv(AG_Event *event)
{
	VG_View *vv = AG_PTR(1);
	AG_WidgetFocus(vv);
	VG_ViewSelectTool(vv, AG_PTR(2), AG_PTR(3));
}

/* VG_View must be locked */
VG_Tool *
VG_ViewFindTool(VG_View *vv, const char *name)
{
	VG_Tool *tool;

	TAILQ_FOREACH(tool, &vv->tools, tools) {
		if (strcmp(tool->ops->name, name) == 0)
			return (tool);
	}
	return (NULL);
}

/* VG_View must be locked */
VG_Tool *
VG_ViewFindToolByOps(VG_View *vv, const VG_ToolOps *ops)
{
	VG_Tool *tool;

	TAILQ_FOREACH(tool, &vv->tools, tools) {
		if (tool->ops == ops)
			return (tool);
	}
	return (NULL);
}

VG_Tool *
VG_ViewRegTool(VG_View *vv, const VG_ToolOps *ops, void *p)
{
	VG_Tool *t;

	t = Malloc(ops->len);
	t->ops = ops;
	t->vgv = vv;
	t->p = p;

	AG_ObjectLock(vv);
	VG_ToolInit(t);
	TAILQ_INSERT_TAIL(&vv->tools, t, tools);
	AG_ObjectUnlock(vv);
	return (t);
}

void
VG_ViewSetScaleMin(VG_View *vv, float scaleMin)
{
	AG_ObjectLock(vv);
	vv->scaleMin = MAX(scaleMin,1e-6f);
	AG_ObjectUnlock(vv);
}

void
VG_ViewSetScaleMax(VG_View *vv, float scaleMax)
{
	AG_ObjectLock(vv);
	vv->scaleMax = scaleMax;
	AG_ObjectUnlock(vv);
}

void
VG_ViewSetScale(VG_View *vv, float scale)
{
	float scalePrev = vv->scale;

	AG_ObjectLock(vv);
	vv->scale = scale;
	if (vv->scale < vv->scaleMin) { vv->scale = vv->scaleMin; }
	if (vv->scale > vv->scaleMax) { vv->scale = vv->scaleMax; }

	vv->wPixel = 1.0/vv->scale;
	vv->x *= (vv->scale/scalePrev);
	vv->y *= (vv->scale/scalePrev);
	AG_ObjectUnlock(vv);
}

void
VG_ViewSetDefaultTool(VG_View *vv, VG_Tool *tool)
{
	AG_ObjectLock(vv);
	vv->deftool = tool;
	AG_ObjectUnlock(vv);
}

void
VG_Status(VG_View *vv, const char *fmt, ...)
{
	va_list ap;

	if (fmt != NULL) {
		va_start(ap, fmt);
		Vsnprintf(vv->status, sizeof(vv->status), fmt, ap);
		va_end(ap);
	} else {
		vv->status[0] = '\0';
	}
}

AG_WidgetClass vgViewClass = {
	{
		"AG_Widget:VG_View",
		sizeof(VG_View),
		{ 0,0 },
		Init,
		NULL,		/* free */
		Destroy,
		NULL,		/* load */
		NULL,		/* save */
		NULL		/* edit */
	},
	Draw,
	SizeRequest,
	SizeAllocate
};
