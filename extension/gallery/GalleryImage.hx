package extension.gallery;

import haxe.io.Bytes;

class GalleryImage {
	public var name: String;
	public var type: String;
	public var bytes: Bytes;

	public function new(name: String, type: String, bytes: Bytes) {
		this.name = name;
		this.type = type;
		this.bytes = bytes;
	}
}