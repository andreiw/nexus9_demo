/*
 * Copyright (C) 2014 Andrei Warkentin <andrey.warkentin@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <inttypes.h>

#define FB_BASE 0xac001000
#define FB_COLS 1536
#define FB_ROWS 2048

void draw_pixel(int x, int y)
{
	uint32_t *fb = (uint32_t *) FB_BASE;

	/* Black. */
	fb[FB_COLS * y + x] = 0x0;
}

void bres(int x1, int y1, int x2, int y2)
{
	int dx, dy, i, e;
	int incx, incy, inc1, inc2;
	int x,y;

	dx = x2 - x1;
	dy = y2 - y1;

	if(dx < 0) dx = -dx;
	if(dy < 0) dy = -dy;
	incx = 1;
	if(x2 < x1) incx = -1;
	incy = 1;
	if(y2 < y1) incy = -1;
	x=x1;
	y=y1;

	if(dx > dy)
	{
		draw_pixel(x,y);
		e = 2*dy - dx;
		inc1 = 2*( dy -dx);
		inc2 = 2*dy;
		for(i = 0; i < dx; i++)
		{
			if(e >= 0)
			{
				y += incy;
				e += inc1;
			}
			else e += inc2;
			x += incx;
			draw_pixel(x,y);
		}
	}
	else
	{
		draw_pixel(x,y);
		e = 2*dx - dy;
		inc1 = 2*( dx - dy);
		inc2 = 2*dx;
		for(i = 0; i < dy; i++)
		{
			if(e >= 0)
			{
				x += incx;
				e += inc1;
			}
			else e += inc2;
			y += incy;
			draw_pixel(x,y);
		}
	}
}

void demo(void)
{
	bres(0, 0, FB_COLS - 1, FB_ROWS - 1);
	bres(FB_COLS - 1, 0, 0, FB_ROWS - 1);
	bres(1, 0, FB_COLS - 1, FB_ROWS - 2);
	bres(FB_COLS - 2, 0, 0, FB_ROWS - 2);
}
