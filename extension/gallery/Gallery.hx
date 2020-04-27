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
			#end

			#if ios
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

			#if android
			gallery_get_image_jni(
				{
					deviceGalleryFileSelectCallback: {
						function(path: String) {
						var bytes: haxe.io.Bytes = null;
						try {
							trace(path);
							var parts = path.split(";");
							trace(parts);
							bytes = sys.io.File.getBytes(parts[0]);
							trace(bytes.length);
							handler(new GalleryImage("", "", bytes));
						} catch(e: Dynamic) {
							trace(e);
						}
					}
					}
				});
			#end
		});
	}
	
	#if android
	private static var gallery_get_image_jni = JNI.createStaticMethod ("org.haxe.extension.Gallery", "getImage", "(Lorg/haxe/lime/HaxeObject;)V");
	#end
	
	#if ios
	private static var gallery_get_image = CFFI.load ("gallery", "gallery_get_image", 1);
	#end
	
}