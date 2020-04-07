#ifndef GALLERY_H
#define GALLERY_H


namespace gallery {
	
	const void getImage(value cb);
	const bool checkAppDirectory();
	
	const void call_callback(const char* strdir);
	
	static void *rootViewController = NULL;
}


#endif