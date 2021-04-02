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

// //This file is not used at present

// package org.sien.qfandid;

// import android.content.Context;
// import android.content.Intent;
// import android.app.Notification;
// import android.app.NotificationManager;
// import android.app.PendingIntent;
// import android.graphics.BitmapFactory;
// import android.app.NotificationChannel;
// import android.app.Service;
// import android.os.IBinder;
// import org.qtproject.qt5.android.bindings.QtService;

// public class ForegroundMessageService extends Service
// {
//     public ForegroundMessageService() {}

//     //native means that this is a C++ function
//     private static native void javaUnseenMessages(int count);

//     @Override
//     public IBinder onBind(Intent intent) {return null;}

//     @Override
//     public void onDestroy()
//     {
//         super.onDestroy();
//         System.out.println("Stopping foreground messages service");
//         stopForeground(true);
//     }

//     @Override
//     public int onStartCommand(Intent intent, int flags, int startId)
//     {
//         int ret = super.onStartCommand(intent, flags, startId);

//         System.out.println("Started notification");

//         NotificationManager m_notificationManager;
//         Notification.Builder m_builder;
//         Context context = getApplicationContext();

//         m_notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

//         if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O)
//         {
//             int importance = NotificationManager.IMPORTANCE_DEFAULT;
//             NotificationChannel notificationChannel = new NotificationChannel("qFandid", "Foreground service", importance);
//             m_notificationManager.createNotificationChannel(notificationChannel);
//             m_builder = new Notification.Builder(context, notificationChannel.getId());
//         }
//         else
//         {
//             m_builder = new Notification.Builder(context);
//         }

//         Intent notificationIntent = new Intent(this, ForegroundMessageService.class);
//         PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);

//         Notification notification = m_builder.setSmallIcon(R.drawable.icon)
//                 .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
//                 .setContentTitle("Foreground service")
//                 .setCategory(Notification.CATEGORY_MESSAGE)
//                 .setTicker("Text")
//                 .build();

//         startForeground(1, notification);

//         return START_STICKY;
//     }
// }
