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
import java.io.File;
import android.net.Uri;
import android.os.Bundle;
import android.content.ContentResolver;
import java.io.InputStream;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.content.ContextWrapper;
import java.lang.Exception;
import java.io.FileOutputStream;
import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.graphics.Rect;

public class MainActivity extends QtActivity
{
    public MainActivity() {}

    //"native" means these are C++ functions
    private static native void javaShareTextToQML(String text);
    private static native void javaCheckNotificationsOnResume();

    public static boolean intentPending;
    public static boolean intentInitialized;
    private boolean firstLaunch = true;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

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

    private void processIntent(Intent intent)
    {
        Uri uri;
        String scheme;
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
//            else if ("image/jpg".equals(type) || "image/jpeg".equals(type) || "image/png".equals(type) || "image/tiff".equals(type) || "image/tif".equals(type) || "image/webp".equals(type) || "image/gif".equals(type))
//            {
//
//            }
        }
    }
}
