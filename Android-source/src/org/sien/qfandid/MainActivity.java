/*    This file is part of qFandid.
 *
 *    qFandid is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    qFandid is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with qFandid.  If not, see <https://www.gnu.org/licenses/>.
 */

package org.sien.qfandid;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.content.Intent;
import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import java.lang.Exception;
import android.app.Activity;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import java.io.InputStream;
import java.io.File;
import java.io.FileOutputStream;

public class MainActivity extends QtActivity
{
    public MainActivity() {}

    //"native" means these are C++ functions
    private static native void javaShareTextToQML(String text);
    private static native void javaShareImageToQML(String path);
    private static native void javaCheckNotificationsOnResume();
    private static native void javaSendBackImage(String path);

    public static boolean intentPending;
    public static boolean intentInitialized;
    private boolean firstLaunch = true;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        //Reset shared preferences containing notification IDs
        SharedPreferences prefs = getSharedPreferences(Activity.class.getSimpleName(), Context.MODE_PRIVATE);
        prefs.edit().clear().commit();

        //Stuff when intent launches app
    }

    @Override
    public void onResume()
    {
        super.onResume();

        if (firstLaunch)
        {
            firstLaunch = false;
            return;
        }

        javaCheckNotificationsOnResume();
    }

    @Override
    public void onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);

        processIntent(intent);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (data != null)
        {
            if (requestCode == 200)
            {
                Uri selectedImageUri = data.getData();
                javaSendBackImage(RealPathUtil.getRealPath(getApplicationContext(), selectedImageUri));
            }
        }
    }

    private void processIntent(Intent intent)
    {
        String action = intent.getAction();
        String type = intent.getType();

        if (Intent.ACTION_SEND.equals(action) && type != null)
        {
            if (type.equals("text/plain"))
            {
                String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
                if (sharedText != null)
                    javaShareTextToQML(sharedText);
            }
            else if (type.startsWith("image/"))
            {
                Uri imageUri = (Uri)intent.getParcelableExtra(Intent.EXTRA_STREAM);
                try
                {
                    InputStream input = getContentResolver().openInputStream(imageUri);
                    Bitmap image = BitmapFactory.decodeStream(input);
                    File file = new File (getApplicationInfo().dataDir, "TempImage.webp");
                    FileOutputStream out = new FileOutputStream(file);

                    if (android.os.Build.VERSION.SDK_INT >= 30)
                        image.compress(Bitmap.CompressFormat.WEBP_LOSSY, 80, out);
                    else
                        image.compress(Bitmap.CompressFormat.WEBP, 80, out);

                    out.flush();
                    out.close();

                    javaShareImageToQML(file.getAbsolutePath());
                }
                catch (Exception e)
                {
                    e.printStackTrace();
                }
            }
        }
    }
}
