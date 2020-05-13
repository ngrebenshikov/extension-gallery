package org.haxe.extension.gallery;

import android.os.Environment;
import android.util.Log;
import java.io.File;
import android.net.Uri;
import android.content.Context;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.content.Intent;
import java.io.*;

public class FileUtils {

	public static File saveUriToCacheFile(Context context, Uri uri) {
		String path = uri.getPath();
        String name = path.substring(path.lastIndexOf("/")+1);
        File file = new File(context.getCacheDir(), name);
        int maxBufferSize = 1024 * 1024;
        try {
        	InputStream  inputStream = context.getContentResolver().openInputStream(uri);
          	int  bytesAvailable = inputStream.available();
          	int bufferSize = Math.min(bytesAvailable, maxBufferSize);
	      	final byte[] buffers = new byte[bufferSize];

            FileOutputStream outputStream = new FileOutputStream(file);
            int read = 0;
            while ((read = inputStream.read(buffers)) != -1) {
                outputStream.write(buffers, 0, read);
            }

            inputStream.close();
            outputStream.close();

            Log.e("saveUriToCacheFile","Path " + file.getPath());
            Log.e("saveUriToCacheFile","Size " + file.length());

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return file;
	}

}
