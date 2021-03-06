#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Gallery.h"


using namespace gallery;



static void gallery_get_image (value cb) {
	getImage(cb);
}
DEFINE_PRIM (gallery_get_image, 1);



extern "C" void gallery_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (gallery_main);



extern "C" int gallery_register_prims () { return 0; }