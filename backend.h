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

#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QApplication>
#include <QString>
#include <qqml.h>

//For debug messages
#include<QDebug>

//For measuring execution times for efficiency
#include <QElapsedTimer>

//For communicating with the host server
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

//For parsing Json responses from the server
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

//For sending information to the server, downloading images
#include <QByteArray>

//For storing key value pairs
#include <QMap>

//For extracting the noun from the full name
#include <QRegularExpression>

//For saving settings in local storage
#include <QSettings>

//For handling network connections within the same function / thread and accessing the reply there
#include <QEventLoop>

//For temporarily loading a downloaded image into memory to determine its format
//DEPRECATED
//#include <QBuffer>

//For determining the format of the downloaded image
//DEPRECATED
//#include <QImageReader>

//For finding platform-specific directories
#include <QStandardPaths>

//For searching the local file system with wildcards to find if an image is already cached
//DEPRECATED
//#include <QDir>

//For reading and writing files on the local file system
#include <QSaveFile>
#include <QFile>

//For emitting delayed signals
#include <QTimer>

//For handling Android requirements like permissions and other specifics
//QtAndroid must be conditionally included, because these libraries are only available on Android so attempting to use them elsewhere will result in compilation failure
#ifdef Q_OS_ANDROID
#include <QtAndroid>

//For properly parsing local filesystem paths on Android
#include <qqmlfile.h>

//For executing Java functions from C++, sending and receiving values
#include <QAndroidJniObject>

//For starting the background service on demand
//DEPRECATED
//#include <QAndroidIntent>

//For registering native C++ functions that can be called from java
#include <QAndroidJniEnvironment>
#endif

//For desktop tray notifications on Windows, Linux and MacOS
#include <QSystemTrayIcon>

//For inserting text into the clipboard on Windows, Linux and MacOS
#include <QClipboard>

//For opening images with external programs on Windows, Linux and MacOS
#include <QDesktopServices>

//For keeping track of which unseen messages have already been notified
//#include <QVector>

//For communication across separate threads
#include <QMetaObject>

//For storing arbitrary data types into one list
#include <QVariant>

//For calculating the cache size
#include <QDirIterator>

//For making the program restart itself
#include <QProcess>

//For applying Material style
#include <QQuickStyle>

//For registration through a web view
#include <QtWebView>

//For embedding C++ objects into QML with context properties
//#include <QQmlContext>

class BackEnd : public QObject
{
    Q_OBJECT

    QML_ELEMENT

public:
    explicit BackEnd(QObject *parent = nullptr);

    //For getting the BackEnd instance in order to access and send signals from static methods
    //When a callback C++ function is called from Java, it must always be static, so there must be a way
    //for the static functions to access the instance where the QML interface resides in order to emit signals to it
    static BackEnd *getQmlInstance()
    {
        return m_instance;
    }

    QString getUserToken();

    //Android-exclusive
    #ifdef Q_OS_ANDROID

    Q_INVOKABLE bool androidCheckStoragePermission();
    Q_INVOKABLE void androidRequestStoragePermission();
    //Q_INVOKABLE void startBackgroundMessagesService(int messageCheckInterval);
    //Q_INVOKABLE void registerJavaCallbacks();

    //static void shareTextToQML(JNIEnv *env, jobject, jstring text);

    #endif

    //Q_INVOKABLE means functions that can be called from QML directly
    //They must be public
    Q_INVOKABLE void storeQmlInstance();

    Q_INVOKABLE QString getCacheDir();
    Q_INVOKABLE void getFeed(int type, int id, int groupId, QString groupSearch, int notificationId, QString userToken);
    Q_INVOKABLE void resetLastId();
    Q_INVOKABLE QString getLoginToken();
    Q_INVOKABLE QString logIn(QString username, QString password, bool rememberMe);
    Q_INVOKABLE void loadImage(QString imageHash, QString imageType, QString id, QString userToken, bool doNotLoadOutside, bool privateImage);
    Q_INVOKABLE void vote(QString type, int id, int voteAction, QString userToken);
    Q_INVOKABLE void joinGroup(bool action, int groupId, QString userToken);
    Q_INVOKABLE void followPost(bool action, int postId, QString userToken);
    Q_INVOKABLE void createComment(QString content, int postId, int parentId, QString userToken);
    Q_INVOKABLE bool prepareImage(QUrl path);
    Q_INVOKABLE void cancelImage();
    Q_INVOKABLE void makeNotification(QString title, QString message);
    Q_INVOKABLE void makePushNotification(int roomId, int yourId, int postId, QString lastMsg, QString oneVn, QString oneColor, QString oneAvatar, QString twoVn, QString twoColor, QString twoAvatar);
    Q_INVOKABLE void createPost(QString content, int groupId, bool nsfw, QString userToken);
    Q_INVOKABLE void saveImage(QString name);
    Q_INVOKABLE void deletePostOrComment(int type, int postId, int commentId, QString userToken);
    Q_INVOKABLE void sharePostOrComment(QString text);
    Q_INVOKABLE void openImageExternally(QString path);
    Q_INVOKABLE void startDirectMessageLongPolling(int roomId, QString userToken);
    Q_INVOKABLE void sendDirectMessage(int roomId, int postId, int commentId, QString content, bool newRoom, QString userToken);
    Q_INVOKABLE void blockDirectMessage(int roomId, QString userToken);
    Q_INVOKABLE void getDirectMessageInfo(int postId, int commentId, QString userToken);
    Q_INVOKABLE void checkNotificationsBackground(QString userToken);
    Q_INVOKABLE void startSystemTrayIcon();
    Q_INVOKABLE void fetchUserInfo(QString userToken);
    Q_INVOKABLE void saveUserSettings(QVariantMap userSettings);
    Q_INVOKABLE void setLightMode(bool enabled);
    Q_INVOKABLE QVariantMap fetchUserSettings();
    Q_INVOKABLE void setNsfw(int nsfw, QString userToken);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void modAction(QString action, int type, int id, QString userToken);
    Q_INVOKABLE QString getCacheSize();
    Q_INVOKABLE void clearCache();
    Q_INVOKABLE void modJoinGroups(QString userToken);
    Q_INVOKABLE void createGroup(QString name, QString description, bool nsfw, QString userToken);
    Q_INVOKABLE void restartProgram();
    Q_INVOKABLE void resetSkipId();
    Q_INVOKABLE void checkAppVersion(QString appVersion);
    Q_INVOKABLE QString readText(QString path);
    Q_INVOKABLE QString registerAccount(QString username, QString password, QString token, bool rememberMe);

    enum RequestType
   {
        NEW,
        HOT,
        GROUPPOSTS,
        SUGGESTEDGROUPS,
        GROUPSEARCH,
        COMMENTS,
        POSTTOGROUPENTRY,
        ROOMLIST,
        CHATMESSAGES,
        NOTIFICATIONS,
        MYPOSTS,
        FOLLOWEDPOSTS,
        JOINEDGROUPS,
        MODLOG,
        CONTENTSEARCH
   };
   Q_ENUMS(RequestType)

   //For exposing the above enums in QML
   static void registerRequestTypeInQML()
   {
       qmlRegisterType<BackEnd>("RequestType", 1, 0, "RequestType");
   }

signals:
   void debugSignal(int keyboardHeight);

    void loginFailed();

    void addPost(int pid, int id, int model, int groupId, bool isOwnPost, bool isClicked, bool isFollowed, QString avatar, QString name, QString time,
                 int riskLevel, QString colorCode, QString group, QString text, QString media, QString imageHash, QString imageType, int imageWidth, int imageHeight, int love, int hate, int comment, int vote);

    void unlockPostFeed();
    void reachedFeedEnd();

    void addComment(int pid, int id, int riskLevel, int model, int postId, int parentId, QString time, int love, int hate, int vote, bool op, bool own, QString avatar,
                    QString name, QString colorCode, QString content, QString media, QString imageHash, QString imageType, int imageWidth, int imageHeight);

    void submitFailed();

    void uploadProgress(QString progress);

    void addGroupInfo(int groupId, int postCount, int memberCount, int model, int riskLevel, QString groupName, QString description, bool own, bool joined);

    void addRoomList(int id, QString time, int postId, int commentId, int yourId, int model, QString lastMsg, QString oneAvatar, QString twoAvatar, QString oneVn, QString oneColor, QString twoVn, QString twoColor, bool seen, bool blocked, bool youBlocked);

    void addChatMessage(bool newMessage, int id, QString time, int senderId, int model, QString content, QString media, QString imageHash, QString imageType, int imageWidth, int imageHeight);

    void addNotification(int id, int postId, int commentId, int count, int model, QString postContent, QString commenterAvatar, QString commentVn, bool own, bool seen);

    void blurhashReady();
    void imageReady(bool cached);

    void postFinished();

    void postOrCommentRemoved();

    void directMessageSuccessful(bool newRoom, int replyId);
    void blockedDirectMessage();
    void directMessageInfo(bool exists, int roomId, QString oneVn, QString oneColor, QString twoVn, QString twoColor);
    void unseenMessagesCounted(int unseenMessages);
    void newCommentsCounted(int newComments);

    void sendSharedTextToQML(QString sharedText);
    void sendImagePathToQML(QString path);

    void sendUserInfo(QVariantMap userInfo);

    void groupCreated();

    void virtualKeyboardHeightChanged(int keyboardHeight);

    void openDirectMessageFromNotification(int roomId, int yourId, int postId, QString oneVn, QString oneColor, QString oneAvatar, QString twoVn, QString twoColor, QString twoAvatar);

private:
    static BackEnd *m_instance;

    void loadBlurhash(QString filename, QString blurhash);

    QString parsePostTime(int seconds);
    QString parseHyperlinks(QString originalText);
    void makeMessageNotification(QString title, QString message);

    void sendPost(QJsonObject jsonObj);
    void sendComment(QJsonObject jsonObj);
    void sendGroupInfo(QJsonObject jsonObj);
    void sendRoomList(QJsonObject jsonObj);
    void sendChatMessage(QJsonObject jsonObj, bool newMessage);
    void sendNotification(QJsonObject jsonObj);

    QString userToken;
    int lastId = 0;
    int skipId = 0;
    QString postTime = "Void";
    QString imageToUploadBase64 = "";
    QSystemTrayIcon trayIcon;

    //Constant values
    //Nouns associated with the corresponding unicode value in the custom font
    const QMap<QString, QString> avatars
    {
        {"Ant", "\ue900"},
        {"Axolotl", "\ue901"},
        {"Bat", "\ue902"},
        {"Beaver", "\ue903"},
        {"Bee", "\ue904"},
        {"Bug", "\ue905"},
        {"Cat", "\ue906"},
        {"Chameleon", "\ue907"},
        {"Chicken", "\ue908"},
        {"Crab", "\ue909"},
        {"Crow", "\ue90a"},
        {"Deer", "\ue90b"},
        {"Doe", "\ue90c"},
        {"Dolphin", "\ue90d"},
        {"Dragon", "\ue90e"},
        {"Duck", "\ue90f"},
        {"Elephant", "\ue910"},
        {"Fish", "\ue911"},
        {"Flamingo", "\ue912"},
        {"Fly", "\ue913"},
        {"Fox", "\ue914"},
        {"Kangaroo", "\ue915"},
        {"Koala", "\ue916"},
        {"Lion", "\ue917"},
        {"Lobster", "\ue918"},
        {"Mod", "\ue919"},
        {"Moth", "\ue91a"},
        {"Mouse", "\ue91b"},
        {"Octopus", "\ue91c"},
        {"Owl", "\ue91d"},
        {"Parrot", "\ue91e"},
        {"Penguin", "\ue91f"},
        {"Pig", "\ue920"},
        {"Raccoon", "\ue921"},
        {"Raptor", "\ue922"},
        {"Shark", "\ue923"},
        {"Sheep", "\ue924"},
        {"Shrimp", "\ue925"},
        {"Snail", "\ue926"},
        {"Snake", "\ue927"},
        {"Spider", "\ue928"},
        {"Squid", "\ue929"},
        {"Starfish", "\ue92a"},
        {"Tiger", "\ue92b"},
        {"Turtle", "\ue92c"},
        {"Unicorn", "\ue92d"},
        {"Whale", "\ue92e"},
        {"Wolf", "\ue92f"},
    };

    const QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/";
    const QString downloadDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + "/";

    const QString host = "https://api.fandid.app/";
    const QString versionSource = "https://fandid.app/qt/version";
    const QString registerType = "v0";

    const QMap<int, QString> feedType
    {
        {RequestType::NEW, "post/getnewposts/"},
        {RequestType::HOT, "post/gethotposts/"},
        {RequestType::GROUPPOSTS, "post/getgroupposts/"},
        {RequestType::SUGGESTEDGROUPS, "group/getsuggestedgroups"},
        {RequestType::GROUPSEARCH, "group/search/"},
        {RequestType::COMMENTS, "comment/asc/"},
        {RequestType::POSTTOGROUPENTRY, "group/search/"},
        {RequestType::ROOMLIST, "chat/rooms/"},
        {RequestType::CHATMESSAGES, "chat/msgs/"},
        {RequestType::NOTIFICATIONS, "notif/desc/"},
        {RequestType::MYPOSTS, "post/getmyposts/"},
        {RequestType::FOLLOWEDPOSTS, "post/getfollowedposts/"},
        {RequestType::JOINEDGROUPS, "group/getfollowedgroups/"},
        {RequestType::MODLOG, "mod/log/0"},
        {RequestType::CONTENTSEARCH, "post/search/"}
    };

private slots:
    //Functions that are automatically executed from signals within the same C++ class object
    void finishedGettingFeed(QNetworkReply *reply);
    void finishedDownloadingImage(QNetworkReply *reply);
    void uploadingProgress(qint64 bytesSent, qint64 bytesTotal);
    void finishedUploadingComment(QNetworkReply *reply);
    void finishedGettingNewDirectMessage(QNetworkReply *reply);
    void directMessageFinished(QNetworkReply *reply);
    void finishedGettingDirectMessageInfo(QNetworkReply *reply);
    void finishedCheckingNotificationsBackground(QNetworkReply *reply);
    void finishedCheckingDirectMessageNotificationsBackground(QNetworkReply *reply);
    void finishedFetchingUserInfo(QNetworkReply *reply);
    void receivedUpdateCheck(QNetworkReply *reply);

protected:
    //DO NOT create a shared QNetworkAccessManager because it will cause conflicts
    //QNetworkAccessManager *manager;
};

#endif // BACKEND_H
