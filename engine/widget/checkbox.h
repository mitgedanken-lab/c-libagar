/*	$Csoft: checkbox.h,v 1.6 2002/06/01 09:29:28 vedge Exp $	*/
/*	Public domain	*/

struct checkbox {
	struct	 widget wid;

	int	 flags;
#define CHECKBOX_PRESSED	0x01

	char		*caption;
	SDL_Surface	*label_s;

	int	 xspacing;	/* Horiz spacing */
	int	 cbox_w;	/* Checkbox width */

	enum {
		CHECKBOX_LEFT,	/* Left of label */
		CHECKBOX_RIGHT	/* Right of label */
	} justify;
};

struct checkbox	*checkbox_new(struct region *, char *, int);
void		 checkbox_init(struct checkbox *, char *, int);
void		 checkbox_destroy(void *);

void	 checkbox_draw(void *);

