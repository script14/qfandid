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

#include <QApplication>
#include <QQmlApplicationEngine>
#include "backend.h"

#ifdef Q_OS_ANDROID
static void shareTextToQML(JNIEnv *env, jobject thiz, jstring text)
{
    Q_UNUSED(thiz);
    emit BackEnd::getQmlInstance()->sendSharedTextToQML(env->GetStringUTFChars(text, nullptr));
}

static void checkNotificationsOnResume(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);
    BackEnd *qmlInstance = BackEnd::getQmlInstance();
    //This is to invoke a method that triggers signals on the main thread
    QMetaObject::invokeMethod(qmlInstance, "checkNotificationsBackground", Qt::AutoConnection, Q_ARG(QString, qmlInstance->getUserToken()));
}

static void startDirectMessageFromNotification(JNIEnv *env, jobject thiz, jint roomId, jint yourId, jint postId, jstring oneVn, jstring oneColor, jstring oneAvatar, jstring twoVn, jstring twoColor, jstring twoAvatar)
{
    Q_UNUSED(thiz);
    emit BackEnd::getQmlInstance()->openDirectMessageFromNotification((int)roomId, (int)yourId, (int)postId,
        env->GetStringUTFChars(oneVn, nullptr), env->GetStringUTFChars(oneColor, nullptr), env->GetStringUTFChars(oneAvatar, nullptr),
        env->GetStringUTFChars(twoVn, nullptr), env->GetStringUTFChars(twoColor, nullptr), env->GetStringUTFChars(twoAvatar, nullptr));
}

static void startPostFromNotification(JNIEnv *env, jobject thiz, jint postId)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);
    emit BackEnd::getQmlInstance()->openPostFromNotification((int)postId);
}

static void storeNotificationId(JNIEnv *env, jobject thiz, jint roomOrCommentId, jint notificationId)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);
    BackEnd::getQmlInstance()->activeNotifications.insert((int)roomOrCommentId, (int)notificationId);
}

//Register special Java callback functions immediately once the app loads because they must be executed if the app is started via external Android intents
//Also because this is the only way to register natives into a Java class that extends QtActivity
JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
    Q_UNUSED(reserved);

    JNIEnv* env;
    // get the JNIEnv pointer.
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK)
        return JNI_ERR;

    // search for the Java class which declares the native methods
    jclass mainActivityClass = env->FindClass("org/sien/qfandid/MainActivity");
    if (!mainActivityClass)
        return JNI_ERR;

    jclass backendClass = env->FindClass("org/sien/qfandid/Backend");
    if (!backendClass)
        return JNI_ERR;

    jclass notificationClickReceiverClass = env->FindClass("org/sien/qfandid/NotificationClickReceiver");
    if (!notificationClickReceiverClass)
        return JNI_ERR;

    //Set native method arrays
    JNINativeMethod mainActivityMethods[] = {
        { "javaShareTextToQML", // const char* function name;
            "(Ljava/lang/String;)V", // const char* function signature
            (void *)shareTextToQML // function pointer
        },
        {"javaCheckNotificationsOnResume", "()V", (void *)checkNotificationsOnResume}
    };

    JNINativeMethod BackendMethods[] = {
        {"javaStoreNotificationId", "(II)V", (void *)storeNotificationId}
    };

    JNINativeMethod notificationClickReceiverMethods[] = {
        {"javaStartDirectMessageFromNotification",
        "(IIILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
        (void *)startDirectMessageFromNotification},

        {"javaStartPostFromNotification", "(I)V", (void *)startPostFromNotification}
    };

    // register the native methods
    if (env->RegisterNatives(mainActivityClass, mainActivityMethods, sizeof(mainActivityMethods) / sizeof(mainActivityMethods[0])) < 0)
        return JNI_ERR;

    if (env->RegisterNatives(backendClass, BackendMethods, sizeof(BackendMethods) / sizeof(BackendMethods[0])) < 0)
        return JNI_ERR;

    if (env->RegisterNatives(notificationClickReceiverClass, notificationClickReceiverMethods, sizeof(notificationClickReceiverMethods) / sizeof(notificationClickReceiverMethods[0])) < 0)
        return JNI_ERR;

    return JNI_VERSION_1_6;
}
#endif

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    //Fixes weird white border line that appears on Android when rotating the screen or sleeping and then waking the phone
    //Note: unnecessary if android:theme="@android:style/Theme.NoTitleBar"
    //QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::Round);

    //It is required to initialize the webview before creating the application
    QtWebView::initialize();
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QQuickStyle::setStyle("Material");

    BackEnd::registerRequestTypeInQML();

    #if !defined Q_OS_ANDROID && !defined Q_OS_IOS
    app.setFont(QApplication::font());
    #endif

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
