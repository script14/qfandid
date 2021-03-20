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
// import java.util.Vector;
// import android.os.Handler;
// import android.app.Service;
// import android.os.IBinder;
// import org.qtproject.qt5.android.bindings.QtService;

// import java.io.IOException;
// import okhttp3.OkHttpClient;
// import okhttp3.Request;
// import okhttp3.Response;

// import org.json.simple.JSONArray;
// import org.json.simple.JSONObject;
// import org.json.simple.parser.JSONParser;

// public class BackgroundMessagesService extends Service
// {
//     public BackgroundMessagesService() {}

//     //native means that this is a C++ function
//     private static native void javaUnseenMessages(int count);

//     Handler handler;

//     @Override
//     public IBinder onBind(Intent intent) {return null;}

//     @Override
//     public void onDestroy()
//     {
//         super.onDestroy();
//         System.out.println("Stopping background messages service");
//         handler.removeCallbacksAndMessages(null);
//     }

//     @Override
//     public int onStartCommand(Intent intent, int flags, int startId)
//     {
//         int ret = super.onStartCommand(intent, flags, startId);

//         System.out.println("Started service");

//         int messageCheckInterval = Integer.parseInt(new String(intent.getByteArrayExtra("messageCheckInterval")));
//         String userToken = new String(intent.getByteArrayExtra("userToken"));

//         Vector<Long> notifiedMessages = new Vector<Long>();

//         handler = new Handler();

//         Runnable runnable = new Runnable()
//         {
//             @Override
//             public void run()
//             {
//                 try
//                 {
//                     System.out.println("Interval check");
//                     //javaCheckNewMessages(userToken);

//                     Thread thread = new Thread(new Runnable()
//                     {
//                         @Override
//                         public void run()
//                         {
//                             try
//                             {
//                                 try
//                                 {
//                                     OkHttpClient client = new OkHttpClient();

//                                     Request request = new Request.Builder()
//                                         .url("https://didapi.kresteks.com/chat/rooms/0")
//                                         .addHeader("Accept", "application/json")
//                                         .addHeader("token", userToken)
//                                         .build();

//                                     try (Response response = client.newCall(request).execute())
//                                     {
//                                         JSONParser parser = new JSONParser();
//                                         JSONArray array = (JSONArray)parser.parse(response.body().string());

//                                         int unseenMessages = 0;
//                                         for (int i = 0; i < array.size(); i++)
//                                         {
//                                             JSONObject obj = (JSONObject)array.get(i);
//                                             if (!(Boolean)obj.get("seen") && !notifiedMessages.contains((Long)obj.get("id")))
//                                             {
//                                                 String senderName = (Long)obj.get("yourId") == 2 ? (String)obj.get("oneVn") : (String)obj.get("twoVn");
//                                                 Backend.makePushNotification(getApplicationContext(), senderName, (String)obj.get("lastMsg"));
//                                                 unseenMessages++;
//                                                 notifiedMessages.add((Long)obj.get("id"));
//                                             }
//                                         }

//                                         //javaUnseenMessages(unseenMessages);
//                                     }
//                                 }
//                                 catch (Exception e)
//                                 {
//                                     e.printStackTrace();
//                                 }
//                             }
//                             catch (Exception e)
//                             {
//                                 e.printStackTrace();
//                             }
//                         }
//                     });

//                     thread.start();
//                 }
//                 catch (Exception e)
//                 {
//                     System.out.println(e);
//                 }
//                 finally
//                 {
//                     handler.postDelayed(this, messageCheckInterval);
//                 }
//             }
//         };

//         handler.post(runnable);

//         return ret;
//     }
// }
