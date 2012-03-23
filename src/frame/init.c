#include <stdio.h>
#include <linux/fb.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include "func.h"

extern fbscr_t fb_v;

int init_data(void)
{
	int fd = open_r("/dev/fb0", O_RDWR);

	struct fb_var_screeninfo fb_var;

	if(ioctl(fd, FBIOGET_VSCREENINFO, &fb_var) < 0){
		perror("ioctl");
		exit(1);
	}
	fb_v.w = fb_var.xres;
	fb_v.h = fb_var.yres;
	fb_v.bpp = fb_var.bits_per_pixel;
	fb_v.memo = mmap_r(NULL, fb_v.w*fb_v.h*fb_v.bpp/8, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

	//printf("%d\n%d\n%d\n", fb_v.w, fb_v.h, fb_v.bpp);
	close(fd);
	//*((u32_t *)fb_v.memo + 1024*100 + 500) = GREEN;
	return fd;
}
