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
    private static native void javaSendKeyboardHeightToQml(int keyboardHeight);

    public static boolean intentPending;
    public static boolean intentInitialized;
    private boolean firstLaunch = true;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        //Install listener for virtual keyboard in order to properly resize the screen in the post creator when the keyboard appears
//        final View AppRootView = ((ViewGroup)this.findViewById(android.R.id.content)).getChildAt(0);
//        AppRootView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener()
//        {
//            @Override
//            public void onGlobalLayout()
//            {
//                int ScreenHeight, VirtualKeyboardHeight;
//                Rect WindowFrameRect = new Rect();
//                Rect ContentFrameRect = new Rect();

//                getWindow().getDecorView().getWindowVisibleDisplayFrame(WindowFrameRect);
//                AppRootView.getWindowVisibleDisplayFrame(ContentFrameRect);
//                ScreenHeight = AppRootView.getRootView().getHeight();

//                VirtualKeyboardHeight = (ScreenHeight - (ContentFrameRect.bottom - ContentFrameRect.top) - WindowFrameRect.top);

//                javaSendKeyboardHeightToQml(VirtualKeyboardHeight);
//            }
//        }
//    );

        // Get intent, action and MIME type
//        Intent intent = getIntent();
//        String type = intent.getType();

        //processIntent(intent);

        // if (intent != null)
        //     String action = intent.getAction();
        //     if (action != null)
        //         intentPending = true;
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
        // setIntent(intent);

        // if (intentInitialized)
        //     processIntent(intent);
        // else
        //     intentPending = true;

        processIntent(intent);
    }

    private void processIntent(Intent intent)
    {
        //Backend.makeDmNotification(getApplicationContext(), "Intent", intent.getAction());

        Uri uri;
        String scheme;
        String action = intent.getAction();
        String type = intent.getType();

        // if (intentAction.equals("android.intent.action.SEND"))
        // {
        //     Bundle bundle = intent.getExtras();
        //     intentUri = (Uri)bundle.get(Intent.EXTRA_STREAM);
        //     intentScheme = intentUri.getScheme();
        //     Backend.makeDmNotification(getApplicationContext(), "Intent", intentScheme);
        // }

        if (Intent.ACTION_SEND.equals(action) && type != null)
        {
            if ("text/plain".equals(type))
            {
                String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
                if (sharedText != null)
                    javaShareTextToQML(sharedText);
            }
//            else if ("image/jpg".equals(type) || "image/jpeg".equals(type) || "image/png".equals(type) || "image/tiff".equals(type) || "image/tif".equals(type) || "image/webp".equals(type) || "image/gif".equals(type))
//            {
//                Bundle bundle = intent.getExtras();
//                uri = (Uri)bundle.get(Intent.EXTRA_STREAM);

//                //javaShareImageUriToQML(uri.toString());

//                try
//                {
//                    InputStream is = getContentResolver().openInputStream(uri);

//                    Bitmap bmp = BitmapFactory.decodeStream(is);

//                    ContextWrapper cw = new ContextWrapper(getApplicationContext());
//                    File directory = cw.getDir("imageDir", MODE_PRIVATE);
//                    File mypath = new File(directory, "temporaryImage");

//                    FileOutputStream fos = null;
//                    try
//                    {
//                        fos = new FileOutputStream(mypath);

//                        bmp.compress(Bitmap.CompressFormat.PNG, 100, fos);
//                    }

//                catch (Exception e)
//                {
//                    e.printStackTrace();
//                }
//                finally
//                {
//                    try
//                    {
//                      fos.close();
//                    }
//                    catch (Exception e)
//                    {
//                      e.printStackTrace();
//                    }
//                }
//                    javaShareImagePathToQML(directory.getAbsolutePath() + "/temporaryImage");
//                }
//                catch (Exception e)
//                {
//                    System.out.println(e);
//                }
//            }
        }
    }
}
