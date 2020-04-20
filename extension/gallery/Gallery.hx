package extension.gallery;


import extension.gallery.GalleryImage;
import tink.core.Future;
import tink.core.Promise;
import tink.core.Outcome;
import tink.core.Error;
import lime.system.CFFI;
import lime.system.JNI;


class Gallery {

	public static function getImage(): Promise<GalleryImage> {
		return Future.async(function(handler: GalleryImage -> Void) {
			#if html5
			var fileDialog = new FileDialog("-gallery");
			fileDialog.onLoadEnd = function(name, type, bytes) {
				fileDialog.dispose();
				handler(new GalleryImage(name, type, bytes));
			}
			haxe.Timer.delay(function() { fileDialog.open(); }, 10);
			#elseif ios
			gallery_get_image(function(path: String) {
				var bytes: haxe.io.Bytes = null;
				try {
					trace(path);
					var parts = path.split(";");
					trace(parts);
					bytes = sys.io.File.getBytes(parts[0]);
					handler(new GalleryImage("", "", bytes));
				} catch(e: Dynamic) {
					trace(e);
				}
			});
			#end
		});
	}
	
	// public static function sampleMethod (inputValue:Int):Int {
		
	// 	#if android
		
	// 	var resultJNI = gallery_sample_method_jni(inputValue);
	// 	var resultNative = gallery_sample_method(inputValue);
		
	// 	if (resultJNI != resultNative) {
			
	// 		throw "Fuzzy math!";
			
	// 	}
		
	// 	return resultNative;
		
	// 	#else
		
	// 	return gallery_sample_method(inputValue);
		
	// 	#end
		
	// }
	
	
	// private static var gallery_sample_method = CFFI.load ("gallery", "gallery_sample_method", 1);
	
	// #if android
	// private static var gallery_sample_method_jni = JNI.createStaticMethod ("org.haxe.extension.Gallery", "sampleMethod", "(I)I");
	// #end
	
	#if ios
	private static var gallery_get_image = CFFI.load ("gallery", "gallery_get_image", 1);
	#end
	
}