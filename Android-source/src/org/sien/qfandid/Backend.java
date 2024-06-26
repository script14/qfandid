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

import android.content.Context;
import android.app.Activity;
import android.widget.Toast;
import android.content.Intent;
import android.net.Uri;
import android.support.v4.content.FileProvider;
import java.io.File;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.graphics.BitmapFactory;
import android.app.NotificationChannel;
import android.content.SharedPreferences;
import android.app.PendingIntent;
import android.os.Build;
import android.media.MediaScannerConnection;

public class Backend
{
    public Backend() {}

    private static native void javaStoreNotificationId(int roomOrCommentId, int notificationId);

    private static NotificationManager m_notificationManager;
    private static Notification.Builder m_builder;

    public static void makeToastMessage(Context context, String message)
    {
        ((Activity)context).runOnUiThread(new Runnable()
        {
            public void run()
            {
                Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
            }
        });
    }

    public static void sharePostOrComment(Context context, String text)
    {
        Intent share = new Intent(Intent.ACTION_SEND);
        share.setType("text/plain");
        share.putExtra(Intent.EXTRA_TEXT, text);
        ((Activity)context).startActivity(Intent.createChooser(share, "Share Text"));
    }

    public static void openImageExternally(Context context, String path)
    {
        File file = new File(path);

        Uri uri = FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", file);
        String mime = context.getContentResolver().getType(uri);

        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        intent.setDataAndType(uri, mime);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    public static void makeDmNotification(Context context, int roomId, int yourId, int postId, String lastMsg, String oneVn, String oneColor, String oneAvatar, String twoVn, String twoColor, String twoAvatar)
    {
        try
        {
            m_notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            {
                int importance = NotificationManager.IMPORTANCE_HIGH;
                NotificationChannel notificationChannel = new NotificationChannel("Fandid DMs", "Direct message notifications", importance);
                m_notificationManager.createNotificationChannel(notificationChannel);
                m_builder = new Notification.Builder(context, notificationChannel.getId());
            }
            else
            {
                m_builder = new Notification.Builder(context);
            }

            Intent goToRoom = new Intent(context, NotificationClickReceiver.class);

            goToRoom.putExtra("action", "goToRoom");
            goToRoom.putExtra("roomId", roomId);
            goToRoom.putExtra("yourId", yourId);
            goToRoom.putExtra("postId", postId);
            goToRoom.putExtra("oneVn", oneVn);
            goToRoom.putExtra("oneColor", oneColor);
            goToRoom.putExtra("oneAvatar", oneAvatar);
            goToRoom.putExtra("twoVn", twoVn);
            goToRoom.putExtra("twoColor", twoColor);
            goToRoom.putExtra("twoAvatar", twoAvatar);

            PendingIntent pendingGoToRoom = PendingIntent.getBroadcast(context, 1, goToRoom, PendingIntent.FLAG_UPDATE_CURRENT);

            m_builder.setSmallIcon(R.drawable.icon)
                    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
                    .setContentTitle(yourId == 2 ? oneVn : twoVn)
                    .setContentText(lastMsg)
                    .setCategory(Notification.CATEGORY_MESSAGE)
                    .setDefaults(Notification.DEFAULT_SOUND)
                    .setAutoCancel(true)
                    .setContentIntent(pendingGoToRoom);

            //SharedPreferences is for generating a new ID so each notification can be separate, but also so the IDs can be kept if they need to be changed at a later time
            SharedPreferences prefs = context.getSharedPreferences(Activity.class.getSimpleName(), Context.MODE_PRIVATE);
            int notificationNumber = prefs.getInt("notificationNumber", 2);

            m_notificationManager.notify(notificationNumber, m_builder.build());
            javaStoreNotificationId(roomId, notificationNumber);

            SharedPreferences.Editor editor = prefs.edit();
            notificationNumber++;
            editor.putInt("notificationNumber", notificationNumber);
            editor.commit();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public static void makeMessageNotification(Context context, String title, String message)
    {
        try
        {
            m_notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            {
                int importance = NotificationManager.IMPORTANCE_DEFAULT;
                NotificationChannel notificationChannel = new NotificationChannel("Fandid messages", "Update notifications", importance);
                m_notificationManager.createNotificationChannel(notificationChannel);
                m_builder = new Notification.Builder(context, notificationChannel.getId());
            }
            else
            {
                m_builder = new Notification.Builder(context);
            }

            Intent openLink = new Intent(context, NotificationClickReceiver.class);
            openLink.putExtra("action", "openLink");
            openLink.putExtra("link", "https://fandid.app");
            PendingIntent pendingOpenLink = PendingIntent.getBroadcast(context, 1, openLink, PendingIntent.FLAG_UPDATE_CURRENT);

            m_builder.setSmallIcon(R.drawable.icon)
                    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
                    .setContentTitle(title)
                    .setContentText(message)
                    .setCategory(Notification.CATEGORY_MESSAGE)
                    .setDefaults(Notification.DEFAULT_SOUND)
                    .setAutoCancel(true)
                    .setContentIntent(pendingOpenLink);

            m_notificationManager.notify(0, m_builder.build());
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public static void makeCommentNotification(Context context, int postId, int notificationId, String commentVn, boolean own, String postContent)
    {
        try
        {
            m_notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            {
                int importance = NotificationManager.IMPORTANCE_DEFAULT;
                NotificationChannel notificationChannel = new NotificationChannel("Fandid comments", "Comment notifications", importance);
                m_notificationManager.createNotificationChannel(notificationChannel);
                m_builder = new Notification.Builder(context, notificationChannel.getId());
            }
            else
            {
                m_builder = new Notification.Builder(context);
            }

            Intent goToComment = new Intent(context, NotificationClickReceiver.class);
            goToComment.putExtra("action", "goToComment");
            goToComment.putExtra("postId", postId);
            goToComment.putExtra("notificationId", notificationId);
            PendingIntent pendingGoToComment = PendingIntent.getBroadcast(context, 1, goToComment, PendingIntent.FLAG_UPDATE_CURRENT);

            m_builder.setSmallIcon(R.drawable.icon)
                    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
                    .setContentTitle(commentVn + " commented on " + (own ? "your post" : "the post"))
                    .setContentText(postContent)
                    .setCategory(Notification.CATEGORY_MESSAGE)
                    .setDefaults(Notification.DEFAULT_SOUND)
                    .setAutoCancel(true)
                    .setContentIntent(pendingGoToComment);

            SharedPreferences prefs = context.getSharedPreferences(Activity.class.getSimpleName(), Context.MODE_PRIVATE);
            int notificationNumber = prefs.getInt("notificationNumber", 2);

            m_notificationManager.notify(notificationNumber, m_builder.build());
            javaStoreNotificationId(postId, notificationNumber);

            SharedPreferences.Editor editor = prefs.edit();
            notificationNumber++;
            editor.putInt("notificationNumber", notificationNumber);
            editor.commit();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public static void cancelActiveNotification(int id)
    {
        m_notificationManager.cancel(id);
    }

    public static void makeImageNotification(Context context, String name, String path)
    {
        try
        {
            m_notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            {
                int importance = NotificationManager.IMPORTANCE_LOW;
                NotificationChannel notificationChannel = new NotificationChannel("Fandid saved images", "Saved image notifications", importance);
                m_notificationManager.createNotificationChannel(notificationChannel);
                m_builder = new Notification.Builder(context, notificationChannel.getId());
            }
            else
            {
                m_builder = new Notification.Builder(context);
            }

            Intent openImage = new Intent(context, NotificationClickReceiver.class);
            openImage.putExtra("action", "openImage");
            openImage.putExtra("path", path);
            PendingIntent pendingOpenImage = PendingIntent.getBroadcast(context, 1, openImage, PendingIntent.FLAG_UPDATE_CURRENT);

            m_builder.setSmallIcon(R.drawable.icon)
                    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
                    .setContentTitle("Saved image")
                    .setContentText(name)
                    .setCategory(Notification.CATEGORY_MESSAGE)
                    .setAutoCancel(true)
                    .setContentIntent(pendingOpenImage);

            SharedPreferences prefs = context.getSharedPreferences(Activity.class.getSimpleName(), Context.MODE_PRIVATE);
            int notificationNumber = prefs.getInt("notificationNumber", 2);

            m_notificationManager.notify(notificationNumber, m_builder.build());

            SharedPreferences.Editor editor = prefs.edit();
            notificationNumber++;
            editor.putInt("notificationNumber", notificationNumber);
            editor.commit();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public static void updateStorage(Context context, String path)
    {
        if (Build.VERSION.SDK_INT >= 29)
        {
            File file = new File(path);
            MediaScannerConnection.scanFile(context, new String[]{file.toString()}, null, null);
        }
        else
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + path)));
    }

    public static void androidOpenFileDialog(Activity activity)
    {
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        activity.startActivityForResult(Intent.createChooser(intent, "Select Picture"), 200);
    }
}
