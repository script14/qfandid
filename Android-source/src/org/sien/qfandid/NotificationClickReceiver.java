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

import android.content.BroadcastReceiver;
import android.content.Context;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;

public class NotificationClickReceiver extends BroadcastReceiver
{
    public NotificationClickReceiver() {}

    private static native void javaStartDirectMessageFromNotification(int roomId, int yourId, int postId, String oneVn, String oneColor, String oneAvatar, String twoVn, String twoColor, String twoAvatar);
    private static native void javaStartPostFromNotification(int postId, int notificationId);

    @Override
    public void onReceive(Context context, Intent intent)
    {
        String action = intent.getStringExtra("action");

        if (action.equals("goToRoom"))
        {
            int roomId = intent.getIntExtra("roomId", 0);
            int yourId = intent.getIntExtra("yourId", 0);
            int postId = intent.getIntExtra("postId", 0);
            String oneVn = intent.getStringExtra("oneVn");
            String oneColor = intent.getStringExtra("oneColor");
            String oneAvatar = intent.getStringExtra("oneAvatar");
            String twoVn = intent.getStringExtra("twoVn");
            String twoColor = intent.getStringExtra("twoColor");
            String twoAvatar = intent.getStringExtra("twoAvatar");

            javaStartDirectMessageFromNotification(roomId, yourId, postId, oneVn, oneColor, oneAvatar, twoVn, twoColor, twoAvatar);

            PackageManager pm = context.getPackageManager();
            Intent launchIntent = pm.getLaunchIntentForPackage(context.getPackageName());
            context.startActivity(launchIntent);
        }
        else if (action.equals("goToComment"))
        {
            int postId = intent.getIntExtra("postId", 0);
            int notificationId = intent.getIntExtra("notificationId", 0);

            javaStartPostFromNotification(postId, notificationId);

            PackageManager pm = context.getPackageManager();
            Intent launchIntent = pm.getLaunchIntentForPackage(context.getPackageName());
            context.startActivity(launchIntent);
        }
        else if (action.equals("openLink"))
        {
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(intent.getStringExtra("link")));
            browserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(browserIntent);
        }
    }
}
