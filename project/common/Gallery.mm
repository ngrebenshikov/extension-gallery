#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <hx/CFFI.h>
#include "Gallery.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface GalleryUIViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
@end

 @implementation GalleryUIViewController
     - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

         UIWindow *window = [UIApplication sharedApplication].keyWindow;
         [picker dismissViewControllerAnimated:YES completion:^{[self dismissViewControllerAnimated:YES completion:nil];}];
         [self removeFromParentViewController];
         [self.view removeFromSuperview];
         [window makeKeyAndVisible];
         NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],1.0);
         UIImage *tmpImage = [UIImage imageWithData:imageData];
         NSString* path = [NSSearchPathForDirectoriesInDomains(
                    NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
         path = [path stringByAppendingString:@"/tmp/tmpFile.jpg"];
         [imageData writeToFile:path atomically:YES];
         NSString* imgOrientation = @"0";
         switch (tmpImage.imageOrientation) {
             case UIImageOrientationDown:
             case UIImageOrientationDownMirrored:
                 imgOrientation = @"180";
                 break;

             case UIImageOrientationLeft:
             case UIImageOrientationLeftMirrored:
                 imgOrientation = @"90";
                 break;

             case UIImageOrientationRight:
             case UIImageOrientationRightMirrored:
                 imgOrientation = @"-90";
                 break;
             case UIImageOrientationUp:
             case UIImageOrientationUpMirrored:
                 break;
         }
         path = [path stringByAppendingString:@";"];
         path = [path stringByAppendingString:imgOrientation];
         const char *cfilename=[path UTF8String];
         gallery::call_callback(cfilename);
         if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
             [UIApplication sharedApplication].statusBarHidden = YES;
         }
    }

    - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [picker dismissViewControllerAnimated:YES completion:^{[self dismissViewControllerAnimated:YES completion:nil];}];
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        [window makeKeyAndVisible];
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            [UIApplication sharedApplication].statusBarHidden = YES;
        }
    }
@end

@interface GalleryUIPopoverController : UIPopoverController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
    - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
@end

@implementation GalleryUIPopoverController
    - (void)imagePickerController : (UIImagePickerController *)picker
                      didFinishPickingMediaWithInfo:(NSDictionary *)info {

        [picker dismissModalViewControllerAnimated:YES];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [self dismissPopoverAnimated:YES];
        [window makeKeyAndVisible];
        NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],1.0);
        UIImage *tmpImage = [UIImage imageWithData:imageData];
        NSString* path = [NSSearchPathForDirectoriesInDomains(
                        NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingString:@"/tmp/tmpFile.jpg"];
        [imageData writeToFile:path atomically:YES];
             NSString* imgOrientation = @"0";
        switch (tmpImage.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                imgOrientation = @"180";
                break;

            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                imgOrientation = @"90";
                break;

            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                imgOrientation = @"-90";
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
        path = [path stringByAppendingString:@";"];
        path = [path stringByAppendingString:imgOrientation];

        const char *cfilename=[path UTF8String];


        gallery::call_callback(cfilename);

        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }
    }
     - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [picker dismissViewControllerAnimated:YES completion:^{[self dismissPopoverAnimated:YES];}];
        [window makeKeyAndVisible];
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            [UIApplication sharedApplication].statusBarHidden = YES;
        }
    }
@end


namespace gallery {

	value *function_callback = NULL;

	const void call_callback(const char* strdir){
        dispatch_async(dispatch_get_main_queue(), ^{
    		val_call1(*function_callback,alloc_string(strdir));
		});
	}	
	
	const void getImage(value cb) {
		
		if (!checkAppDirectory()) return;

        val_check_function(cb,1);
        function_callback = alloc_root();
        *function_callback = cb;
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        NSArray *supportedOrientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
        if([[UIDevice currentDevice].model isEqual:@"iPad"] && (SYSTEM_VERSION_LESS_THAN(@"7.0") || [[supportedOrientations objectAtIndex:0] rangeOfString:@"Landscape"].location != NSNotFound)){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            GalleryUIPopoverController *wn = [[GalleryUIPopoverController alloc] initWithContentViewController:picker];
            picker.delegate = wn;
            [wn presentPopoverFromRect:CGRectMake(0.0,0.0,400.0,400.0) inView:window permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [picker release];
            [window makeKeyAndVisible];
        } else {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            GalleryUIViewController *wn = [[GalleryUIViewController alloc] init];
            picker.delegate = wn;
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:picker animated:YES completion:nil];
            [picker release];
        }
    }

    const bool checkAppDirectory() {
        NSString* path = [NSSearchPathForDirectoriesInDomains(
                    NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingString:@"/"];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingString:@"tmp"]];
        NSString *filePathAndDirectory;
        NSError *error;
        if (fileExists == TRUE) {
            NSLog(@"already exists folder tmp");
        } else {
            NSLog(@"tmp folder doesn't exist, trying to create it");
            filePathAndDirectory = [path stringByAppendingString:@"tmp"];

            if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                     error:&error]) {
                NSLog(@"Create directory error: %@", error);
                return false;
            }
        }
        return true;
	}
		
}