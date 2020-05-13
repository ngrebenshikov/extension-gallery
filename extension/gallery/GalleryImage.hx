package extension.gallery;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import haxe.io.Bytes;

class GalleryImage {
	public var name: String;
	public var type: String;
	public var bytes: Bytes;
	public var rotation: GalleryImageRotation;

	public function new(name: String, type: String, bytes: Bytes, rotation: GalleryImageRotation) {
		this.name = name;
		this.type = type;
		this.bytes = bytes;
		this.rotation = rotation;
	}

	public static function rotate(bitmap: BitmapData, rotation: GalleryImageRotation) {
		var width = switch(rotation) {
			case D0: bitmap.width;
			case D90: bitmap.height;
			case D180: bitmap.width;
			case D270: bitmap.height;
		};
		var height = switch(rotation) {
			case D0: bitmap.height;
			case D90: bitmap.width;
			case D180: bitmap.height;
			case D270: bitmap.width;
		};

		var result: BitmapData = new BitmapData(width, height);

		var rotationMatrix: Matrix = new Matrix();
		rotationMatrix.rotate(rotationToFloat(rotation)*Math.PI/180.0);
		rotationMatrix.translate(
			switch(rotation) {
				case D0: 0;
				case D90: bitmap.height;
				case D180: bitmap.width;
				case D270: 0;
			},
			switch(rotation) {
				case D0: 0;
				case D90: 0;
				case D180: bitmap.height;
				case D270: bitmap.width;
			}
		);

		result.draw(bitmap, rotationMatrix);

		return result;
	}

	public static function parseAndInvertRotation(s: String): GalleryImageRotation {
		return switch(s) {
			case "0": D0;
			case "90": D270;
			case "180": D180;
			case "-90": D90;
			case "270": D90;
			default: D0;
		};
	}

	private static function rotationToFloat(rotation: GalleryImageRotation): Float {
		return switch(rotation) {
			case D0: 0.0;
			case D90: 90.0;
			case D180: 180.0;
			case D270: 270.0;
		}
	}

}