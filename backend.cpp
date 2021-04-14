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

#include "backend.h"

//For the third-party blurhash portable C decoder library
extern "C" {
#ifndef STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#endif
#include "blurhashC/decode.h"
#include "blurhashC/stb_writer.h"
}

BackEnd *BackEnd::m_instance = nullptr;

BackEnd::BackEnd(QObject *parent) : QObject(parent) {}

void BackEnd::storeQmlInstance()
{
    m_instance = this;
}

#ifdef Q_OS_ANDROID
bool BackEnd::androidCheckStoragePermission()
{
    QtAndroid::PermissionResult permissionResult = QtAndroid::checkPermission(QString("android.permission.READ_EXTERNAL_STORAGE"));

    return permissionResult == QtAndroid::PermissionResult::Granted ? true : false;
}

void BackEnd::androidRequestStoragePermission()
{
    QtAndroid::requestPermissionsSync(QStringList({"android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE"}));
}
#endif

QString BackEnd::getUserToken()
{
    return userToken;
}

QString BackEnd::getCacheDir()
{
    return cacheDir;
}

QString BackEnd::parsePostTime(int seconds)
{
    int firstTime = 0;
    int secondTime = 0;
    if (seconds >= 31556952)
    {
        firstTime = seconds / 31556952;
        secondTime = seconds % 31556952 / 2629746;
        return QString::number(firstTime) + QString("y ") + QString::number(secondTime) + QString("m");
    }
    else if (seconds >= 2629746)
    {
        firstTime = seconds / 2629746;
        secondTime = seconds % 2629746 / 604800;
        return QString::number(firstTime) + QString("m ") + QString::number(secondTime) + QString("w");
    }
    else if (seconds >= 604800)
    {
        firstTime = seconds / 604800;
        secondTime = seconds % 604800 / 86400;
        return QString::number(firstTime) + QString("w ") + QString::number(secondTime) + QString("d");
    }
    else if (seconds >= 86400)
    {
        firstTime = seconds / 86400;
        secondTime = seconds % 86400 / 3600;
        return QString::number(firstTime) + QString("d ") + QString::number(secondTime) + QString("h");
    }
    else if (seconds >= 3600)
    {
        firstTime = seconds / 3600;
        secondTime = seconds % 3600 / 60;
        return QString::number(firstTime) + QString("h ") + QString::number(secondTime) + QString("m");
    }
    else if (seconds >= 60)
    {
        firstTime = seconds / 60;
        secondTime = seconds % 60;
        return QString::number(firstTime) + QString("m ") + QString::number(secondTime) + QString("s");
    }
    else
    {
        return QString::number(seconds) + QString("s ");
    }

    return QString("Void");
}

QString BackEnd::escapeText(QString originalText)
{
    //Due to C++ literal strings rules, all backslashes inside the pattern must be escaped with another backslash
    QRegularExpression regex("(((https?://)|(www\\.))\\S+)");
    //color fandidYellow: "#FFC20B"
    return originalText.replace(QRegularExpression("&"), "&amp;")
            .replace(QRegularExpression("<"), "&lt;")
            .replace(QRegularExpression(">"), "&gt;")
            .replace(regex, "<a href='\\1' style='color:#FFC20B;'>\\1</a>")
            .replace(QRegularExpression("\n"), "<br>");
}

QString BackEnd::unescapeText(QString originalText)
{
    return originalText.replace(QRegularExpression("&amp;"), "&")
            .replace(QRegularExpression("&lt;"), "<")
            .replace(QRegularExpression("&gt;"), ">")
            .replace(QRegularExpression("<br>"), "\n")
            .replace(QRegularExpression("<a href='.*;'>(.*)<\\/a>"), "\\1");
}

void BackEnd::getFeed(int type, int id, int groupId, QString groupSearch, int notificationId, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);

    //connect is used to make a connection between a Qt signal and a slot. When the manager->get() function finishes executing, it automatically emits a signal that it has finished.
    //This connect line means that we're connecting that signal to the function (or slot) "finishedGettingFeed" which is defined in "this" class
    //In other words, when the QNetworkAccessManager finally receives a response from the server, it will automatically call the function to parse it and send it to the QML
    //This all happens in a separate thread so the interface can remain responsive
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedGettingFeed);

    QNetworkRequest request;

    switch (type)
    {
        case RequestType::NEW:
        case RequestType::HOT:
        case RequestType::ROOMLIST:
        case RequestType::MYPOSTS:
        case RequestType::FOLLOWEDPOSTS:
        case RequestType::NOTIFICATIONS:
        case RequestType::JOINEDGROUPS:
            request.setUrl(QUrl(host + feedType[type] + QString::number(lastId)));
            break;
        case RequestType::GROUPPOSTS:
            request.setUrl(QUrl(host + feedType[type] + QString::number(groupId) + "/" + QString::number(lastId)));
            break;
        case RequestType::SUGGESTEDGROUPS:
        case RequestType::MODLOG:
            request.setUrl(QUrl(host + feedType[type]));
            break;
        case RequestType::GROUPSEARCH:
            request.setUrl(QUrl(host + feedType[type] + groupSearch + "/0"));
            break;
        case RequestType::COMMENTS:
            if (notificationId == 0)
                request.setUrl(QUrl(host + feedType[type] + QString::number(id) + "/" + QString::number(lastId)));
            else
                request.setUrl(QUrl(host + feedType[type] + QString::number(id) + "/" + QString::number(notificationId) + "/" + QString::number(lastId)));
            break;
        case RequestType::CHATMESSAGES:
            request.setUrl(QUrl(host + feedType[type] + QString::number(id) + "/" + QString::number(lastId)));
            break;
        case RequestType::POSTTOGROUPENTRY:
            request.setUrl(QUrl(host + feedType[type] + groupSearch));
            break;
        case RequestType::CONTENTSEARCH:
            //This one is slightly different from the rest

            request.setUrl(QUrl(host + feedType[type] + QString::number(skipId)));
            request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
            request.setRawHeader("token", userToken.toUtf8());

            QJsonObject searchData;
            searchData["content"] = groupSearch;
            searchData["groupId"] = groupId;
            QJsonDocument doc(searchData);
            QByteArray body = doc.toJson();

            QNetworkReply *reply = manager->post(request, body);
            reply->setProperty("contentSearch", true);

            return;
    }

    request.setRawHeader("token", userToken.toUtf8());

    manager->get(request);
}

void BackEnd::finishedGettingFeed(QNetworkReply *reply)
{
    QString response = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(response.toUtf8());

    QJsonArray jsonArray = jsonDoc.array();

    int unlockDelay = 300;

    if (jsonArray.isEmpty())
    {
        QTimer::singleShot(unlockDelay, this, &BackEnd::unlockPostFeed);
        emit reachedFeedEnd();
        return;
    }

    foreach (const QJsonValue &value, jsonArray)
    {
        switch (value.toObject()["model"].toInt())
        {
        case 0:
            sendPost(value.toObject());
            break;
        case 1:
            sendComment(value.toObject());
            break;
        case 3:
            sendNotification(value.toObject());
            unlockDelay = 50;
            break;
        case 2:
        case 7:
        case 9:
            sendGroupInfo(value.toObject());
            break;
        case 5:
            sendRoomList(value.toObject());
            unlockDelay = 20;
            break;
        case 6:
            sendChatMessage(value.toObject(), false);
            unlockDelay = 20;
            break;
        default:
            continue;
        }
    }

    //Unlock the post feed after a short delay to give the list view time to load the posts
    //If this isn't done it's possibe to spam call the server by holding the list view at the end
    QTimer::singleShot(unlockDelay, this, &BackEnd::unlockPostFeed);

    if (reply->property("contentSearch").toBool())
        skipId++;
    else
        lastId = jsonArray.last().toObject()["id"].toInt();
}

void BackEnd::sendPost(QJsonObject jsonObj)
{
    QString name = jsonObj["vn"].toString();
    QString animalNoun = name.compare("Mod") != 0 ? QRegularExpression("[A-Z][a-z]+").globalMatch(name, 1).next().captured(0) : "Mod";

    //Parse time
    postTime = parsePostTime(jsonObj["time"].toInt());

    //Send post to QML
    emit addPost
            (
                jsonObj["pid"].toInt(),
                jsonObj["id"].toInt(),
                jsonObj["model"].toInt(),
                jsonObj["groupId"].toInt(),
                jsonObj["ownPost"].toBool(),
                jsonObj["clicked"].toBool(),
                jsonObj["followed"].toBool(),
                avatars[animalNoun].isEmpty() ? avatars["Placeholder"] : avatars[animalNoun],
                jsonObj["vn"].toString(),
                postTime,
                jsonObj["riskLevel"].toInt(),
                jsonObj["color"].toString(),
                jsonObj["groupName"].toString(),
                escapeText(jsonObj["content"].toString()),
                jsonObj["image"].toString(),
                jsonObj["imageHash"].toString(),
                jsonObj["imageType"].toString(),
                jsonObj["imageWidth"].toInt(),
                jsonObj["imageHeight"].toInt(),
                jsonObj["loveCount"].toInt(),
                jsonObj["hateCount"].toInt(),
                jsonObj["commentCount"].toInt(),
                jsonObj["vote"].toInt()
            );
}

void BackEnd::sendComment(QJsonObject jsonObj)
{
    QString name = jsonObj["vn"].toString();
    QString animalNoun = name.compare("Mod") != 0 ? QRegularExpression("[A-Z][a-z]+").globalMatch(name, 1).next().captured(0) : "Mod";

    emit addComment
            (
                jsonObj["pid"].toInt(),
                jsonObj["id"].toInt(),
                jsonObj["model"].toInt(),
                jsonObj["riskLevel"].toInt(),
                jsonObj["postId"].toInt(),
                jsonObj["parentId"].toInt(),
                parsePostTime(jsonObj["time"].toInt()),
                jsonObj["loveCount"].toInt(),
                jsonObj["hateCount"].toInt(),
                jsonObj["vote"].toInt(),
                jsonObj["op"].toBool(),
                jsonObj["own"].toBool(),
                avatars[animalNoun].isEmpty() ? avatars["Placeholder"] : avatars[animalNoun],
                jsonObj["vn"].toString(),
                jsonObj["color"].toString(),
                escapeText(jsonObj["content"].toString()),
                jsonObj["image"].toString(),
                jsonObj["imageHash"].toString(),
                jsonObj["imageType"].toString(),
                jsonObj["imageWidth"].toInt(),
                jsonObj["imageHeight"].toInt()
             );
}

void BackEnd::sendGroupInfo(QJsonObject jsonObj)
{
    emit addGroupInfo
            (
                jsonObj["id"].toInt(),
                jsonObj["postCount"].toInt(),
                jsonObj["memberCount"].toInt(),
                jsonObj["model"].toInt(),
                jsonObj["riskLevel"].toInt(),
                jsonObj["groupName"].toString(),
                escapeText(jsonObj["description"].toString()),
                jsonObj["own"].toBool(),
                jsonObj["joined"].toBool()
            );
}

void BackEnd::sendRoomList(QJsonObject jsonObj)
{
    QString name1 = jsonObj["oneVn"].toString();
    QString name2 = jsonObj["twoVn"].toString();
    QString oneAnimalNoun = name1.compare("Mod") != 0 ? QRegularExpression("[A-Z][a-z]+").globalMatch(name1, 1).next().captured(0) : "Mod";
    QString twoAnimalNoun = name2.compare("Mod") != 0 ? QRegularExpression("[A-Z][a-z]+").globalMatch(name2, 1).next().captured(0) : "Mod";

    emit addRoomList
            (
                jsonObj["id"].toInt(),
                parsePostTime(jsonObj["time"].toInt()),
                jsonObj["postId"].toInt(),
                jsonObj["commentId"].toInt(),
                jsonObj["yourId"].toInt(),
                jsonObj["model"].toInt(),
                jsonObj["lastMsg"].toString(),
                avatars[oneAnimalNoun],
                avatars[twoAnimalNoun],
                jsonObj["oneVn"].toString(),
                jsonObj["oneColor"].toString(),
                jsonObj["twoVn"].toString(),
                jsonObj["twoColor"].toString(),
                jsonObj["seen"].toBool(),
                jsonObj["blocked"].toBool(),
                jsonObj["youBlocked"].toBool()
            );
}

void BackEnd::sendChatMessage(QJsonObject jsonObj, bool newMessage)
{
    emit addChatMessage
            (
                newMessage,
                jsonObj["id"].toInt(),
                parsePostTime(jsonObj["time"].toInt()),
                jsonObj["senderId"].toInt(),
                jsonObj["model"].toInt(),
                escapeText(jsonObj["content"].toString()),
                jsonObj["image"].toString(),
                jsonObj["imageHash"].toString(),
                jsonObj["imageType"].toString(),
                jsonObj["imageWidth"].toInt(),
                jsonObj["imageHeight"].toInt()
            );
}

void BackEnd::sendNotification(QJsonObject jsonObj)
{
    QString name = jsonObj["commentVn"].toString();
    QString animalNoun = name.compare("Mod") != 0 ? QRegularExpression("[A-Z][a-z]+").globalMatch(name, 1).next().captured(0) : "Mod";

    emit addNotification
            (
                jsonObj["id"].toInt(),
                jsonObj["postId"].toInt(),
                jsonObj["commentId"].toInt(),
                jsonObj["count"].toInt(),
                jsonObj["model"].toInt(),
                jsonObj["postContent"].toString(),
                avatars[animalNoun].isEmpty() ? avatars["Placeholder"] : avatars[animalNoun],
                jsonObj["commentVn"].toString(),
                jsonObj["own"].toBool(),
                jsonObj["seen"].toBool()
            );
}

void BackEnd::resetLastId()
{
    lastId = 0;
}

QString BackEnd::getLoginToken()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "qFandid", "qFandid");
    settings.beginGroup("Authentication");
    userToken = settings.value("userToken", QString()).toString();
    settings.endGroup();

    if (!userToken.isEmpty())
        return userToken;
    else
        return QString();
}

QString BackEnd::logIn(QString username, QString password, bool rememberMe)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);

    QNetworkRequest request;
    request.setUrl(QUrl(host + "user/login"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject authData;
    authData["username"] = username;
    authData["password"] = password;

    QJsonDocument doc(authData);
    QByteArray body = doc.toJson();

    QNetworkReply *reply = manager->post(request, body);

    //I use an event loop here to be able to return the token to the QML side within the same function
    //And because nothing else happens on the login page anyway, there's no downside to making a synchronous call
    QEventLoop eventLoop;
    connect(reply, SIGNAL(finished()), &eventLoop, SLOT(quit()));

    eventLoop.exec();

    QString token = QString::fromUtf8(reply->readAll());

    //The server returns an empty string if the credentials are wrong
    if (!token.isEmpty())
    {
        if (rememberMe)
        {
            //Save the user token in an INI file
            QSettings settings(QSettings::IniFormat, QSettings::UserScope, "qFandid", "qFandid");
            settings.beginGroup("Authentication");
            settings.setValue("userToken", token);
            settings.endGroup();
        }

        return token;
    }
    else
    {
        return QString();
    }
}



void BackEnd::loadBlurhash(QString filename, QString blurhash)
{
    //This function is merely a wrapper for the C functions imported from the third-party blurhash portable C decoder library
    //The C functions have not been modified in any way - they are the same as the ones from the source repository

    //int punch = 1;
    //const int nChannels = 4;
    //const int quality = 100;

    //If the image is not already stored in cache, generate a blur placeholder
    if (QFile::exists(filename))
    {
        emit blurhashReady();
    }
    else
    {
        if (!blurhash.isEmpty())
        {
            //The host server encodes the images in 32x32 by default. The images are decoded here in 32x32 too and stretched to the original size in QML
            uint8_t *bytes = decode(blurhash.toLocal8Bit().data(), 32, 32, 1, 4);
            if (bytes)
            {
                stbi_write_jpg(filename.toLocal8Bit().data(), 32, 32, 4, bytes, 100);
                emit blurhashReady();
            }
        }
    }
}

void BackEnd::loadImage(QString imageHash, QString imageType, QString id, QString userToken, bool doNotLoadOutside, bool privateImage)
{
    if (doNotLoadOutside)
        loadBlurhash((cacheDir + id + ".blurhash"), imageHash);

    else if (!QFile::exists(cacheDir + id + "." + imageType))
    {
        loadBlurhash((cacheDir + id + ".blurhash"), imageHash);

        QNetworkAccessManager *manager = new QNetworkAccessManager(this);
        QNetworkRequest request;
        request.setUrl(QUrl(host + (privateImage ? "image/msg/" : "image/img/") + id));
        request.setRawHeader("token", userToken.toUtf8());
        QNetworkReply* reply = manager->get(request);
        connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedDownloadingImage);
        reply->setProperty("id", id);
        reply->setProperty("imageType", imageType);
    }
    else
        emit imageReady(true);
}

void BackEnd::finishedDownloadingImage(QNetworkReply *reply)
{
    QString id = reply->property("id").toString();
    QString imageType = reply->property("imageType").toString();

    QByteArray data = QByteArray::fromBase64(reply->readAll());

//    QBuffer buffer(&data);

//    QImageReader identifier;
//    identifier.setDevice(&buffer);

//    QString extension = identifier.supportsAnimation() ? ".gif" : ".webp";

    QString path = cacheDir + id + "." + imageType;

    QSaveFile file(path);
    file.open(QIODevice::WriteOnly);
    file.write(data);
    file.commit();

    emit imageReady(false);

    //Once the real image is stored in cache, the blurhash version is no longer needed
    //QFile::remove(cacheDir + id + ".blurhash");
}

void BackEnd::vote(QString type, int id, int voteAction, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "vote/" + type + "/" + QString::number(id) + "/" + QString::number(voteAction)));
    request.setRawHeader("token", userToken.toUtf8());
    manager->get(request);
}

void BackEnd::joinGroup(bool action, int groupId, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "group/join/" + QString::number(action) + "/" + QString::number(groupId)));
    request.setRawHeader("token", userToken.toUtf8());
    manager->get(request);
}

void BackEnd::followPost(bool action, int postId, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "post/follow/" + QString::number(action) + "/" + QString::number(postId)));
    request.setRawHeader("token", userToken.toUtf8());
    manager->get(request);
}

void BackEnd::createComment(QString content, int postId, int parentId, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "comment/create"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("token", userToken.toUtf8());

    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedUploadingComment);

    QJsonObject commentData;
    commentData["content"] = content;
    commentData["postId"] = postId;
    commentData["parentId"] = parentId;
    commentData["image"] = imageToUploadBase64;

    QJsonDocument doc(commentData);
    QByteArray body = doc.toJson();

    QNetworkReply *reply = manager->post(request, body);
    connect(reply, &QNetworkReply::uploadProgress, this, &BackEnd::uploadingProgress);
}

bool BackEnd::prepareImage(QUrl path)
{
    QFile *file;

    #ifdef Q_OS_ANDROID
    file = new QFile(QQmlFile::urlToLocalFileOrQrc(path));
    #else
    file = new QFile(path.toLocalFile());
    #endif

    file->open(QIODevice::ReadOnly);
    QByteArray image = file->readAll();

    QString encoded = image.toBase64();
    file->close();

    if (encoded.size() < 12000000)
    {
        imageToUploadBase64 = encoded;
        return true;
    }
    else
        return false;
}

void BackEnd::cancelImage()
{
    imageToUploadBase64 = "";
}

void BackEnd::makeNotification(QString title, QString message)
{
    #ifdef Q_OS_ANDROID

    Q_UNUSED(title);
    QAndroidJniObject javaMessage = QAndroidJniObject::fromString(message);
    QAndroidJniObject::callStaticMethod<void>("org/sien/qfandid/Backend", "makeToastMessage", "(Landroid/content/Context;Ljava/lang/String;)V", QtAndroid::androidContext().object(), javaMessage.object<jstring>());

    #else

    QSystemTrayIcon notificationTrayIcon;
    notificationTrayIcon.setIcon(QIcon(":/Assets/Images/icon.png"));
    notificationTrayIcon.setVisible(true);
    notificationTrayIcon.showMessage(title, message, QSystemTrayIcon::Information, 5000);
    notificationTrayIcon.hide();
    notificationTrayIcon.deleteLater();

    #endif
}

void BackEnd::makeDmNotification(int roomId, int yourId, int postId, QString lastMsg, QString oneVn, QString oneColor, QString oneAvatar, QString twoVn, QString twoColor, QString twoAvatar)
{
    #ifdef Q_OS_ANDROID

    QAndroidJniObject javaLastMsg = QAndroidJniObject::fromString(lastMsg);
    QAndroidJniObject javaOneVn = QAndroidJniObject::fromString(oneVn);
    QAndroidJniObject javaOneColor = QAndroidJniObject::fromString(oneColor);
    QAndroidJniObject javaOneAvatar = QAndroidJniObject::fromString(oneAvatar);
    QAndroidJniObject javaTwoVn = QAndroidJniObject::fromString(twoVn);
    QAndroidJniObject javaTwoColor = QAndroidJniObject::fromString(twoColor);
    QAndroidJniObject javaTwoAvatar = QAndroidJniObject::fromString(twoAvatar);

    QAndroidJniObject::callStaticMethod<void>("org/sien/qfandid/Backend", "makeDmNotification",
                                              "(Landroid/content/Context;IIILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                              QtAndroid::androidContext().object(), roomId, yourId, postId, javaLastMsg.object<jstring>(), javaOneVn.object<jstring>(), javaOneColor.object<jstring>(),
                                              javaOneAvatar.object<jstring>(), javaTwoVn.object<jstring>(), javaTwoColor.object<jstring>(), javaTwoAvatar.object<jstring>());

    #else

    Q_UNUSED(roomId);
    Q_UNUSED(postId);
    Q_UNUSED(oneColor);
    Q_UNUSED(oneAvatar);
    Q_UNUSED(twoColor);
    Q_UNUSED(twoAvatar);
    makeNotification("New message from " + (yourId == 2 ? oneVn : twoVn), lastMsg);

    #endif
}

void BackEnd::uploadingProgress(qint64 bytesSent, qint64 bytesTotal)
{
    emit uploadProgress(QString::number(100 * ((double)bytesSent / (double)bytesTotal), 'f', 0));
}

void BackEnd::finishedUploadingComment(QNetworkReply *reply)
{
    QString response = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(response.toUtf8());

    if (!jsonDoc.isEmpty())
        sendComment(jsonDoc.object());
    else
        emit submitFailed();
}

void BackEnd::createPost(QString content, int groupId, bool nsfw, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);

    QNetworkRequest request;
    request.setUrl(QUrl(host + "post/create"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("token", userToken.toUtf8());

    QJsonObject postData;
    postData["content"] = content;
    postData["groupId"] = groupId;
    postData["riskLevel"] = (int)nsfw;
    postData["image"] = imageToUploadBase64;

    QJsonDocument doc(postData);
    QByteArray body = doc.toJson();

    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::postFinished);
    QNetworkReply *reply = manager->post(request, body);
    connect(reply, &QNetworkReply::uploadProgress, this, &BackEnd::uploadingProgress);
}

void BackEnd::saveImage(QString name)
{
    #ifdef Q_OS_ANDROID

    androidRequestStoragePermission();
    if (!androidCheckStoragePermission())
    {
        makeNotification("Error", "You must grant storage permission to download images");
        return;
    }

    #endif

    if (!QFile::exists(cacheDir + name))
    {
        makeNotification("Error", "Image is not ready");
        return;
    }

    if (QFile::copy(cacheDir + name, downloadDir + name))
        makeNotification("Saved image", "Saved to download directory");
    else
        makeNotification("Error", "Could not save image");
}

void BackEnd::deletePostOrComment(int type, int postId, int commentId, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    if (type == 0)
        request.setUrl(QUrl(host + "post/delete/" + QString::number(postId)));
    else
        request.setUrl(QUrl(host + "comment/delete/" + QString::number(postId) + "/" + QString::number(commentId)));

    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::postOrCommentRemoved);
    manager->get(request);

    #if defined Q_OS_ANDROID || defined Q_OS_IOS
    makeNotification("Deleted", type == 0 ? "Post deleted" : "Comment deleted");
    #endif
}

void BackEnd::sharePostOrComment(QString text)
{
    QString unescapedText = unescapeText(text);

    #ifdef Q_OS_ANDROID

    QAndroidJniObject javaText = QAndroidJniObject::fromString(unescapedText);
    QAndroidJniObject::callStaticMethod<void>("org/sien/qfandid/Backend", "sharePostOrComment", "(Landroid/content/Context;Ljava/lang/String;)V", QtAndroid::androidContext().object(), javaText.object<jstring>());

    #else

    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(unescapedText);
    makeNotification("Shared", "Shared to clipboard");

    #endif
}

void BackEnd::openImageExternally(QString path)
{
    if (!QFile::exists(path))
    {
        makeNotification("Error", "Image is not ready");
        return;
    }

    #ifdef Q_OS_ANDROID

    QAndroidJniObject javaPath = QAndroidJniObject::fromString(path);
    QAndroidJniObject::callStaticMethod<void>("org/sien/qfandid/Backend", "openImageExternally", "(Landroid/content/Context;Ljava/lang/String;)V", QtAndroid::androidContext().object(), javaPath.object<jstring>());

    #else

    QDesktopServices::openUrl(QUrl::fromLocalFile(path));

    #endif
}

void BackEnd::startDirectMessageLongPolling(int roomId, QString userToken)
{
    qDebug() << "Long polling";

    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    manager->setTransferTimeout(60000);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "chat/newmsgs/" + QString::number(roomId) + "/" + QString::number(lastId)));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedGettingNewDirectMessage);
    QNetworkReply* reply = manager->get(request);
    reply->setProperty("roomId", roomId);
    reply->setProperty("userToken", userToken);
}

void BackEnd::finishedGettingNewDirectMessage(QNetworkReply *reply)
{
    qDebug() << "Message received";

    QString response = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(response.toUtf8());

    QJsonArray jsonArray = jsonDoc.array();

    if (!jsonArray.isEmpty())
        sendChatMessage(jsonArray.first().toObject(), true);

    startDirectMessageLongPolling(reply->property("roomId").toInt(), reply->property("userToken").toString());
}

void BackEnd::sendDirectMessage(int roomId, int postId, int commentId, QString content, bool newRoom, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);

    QNetworkRequest request;
    QString url = host + "chat/send/";

    //If sending a message for the first time, a new room needs to be instantiated which uses a different endpoint
    if (newRoom)
        url += QString::number(postId) + "/" + QString::number(commentId);
    else
        url += QString::number(roomId);

    request.setUrl(QUrl(url));

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("token", userToken.toUtf8());

    QJsonObject messageData;
    messageData["content"] = content;
    messageData["image"] = imageToUploadBase64;

    QJsonDocument doc(messageData);
    QByteArray body = doc.toJson();

    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::directMessageFinished);

    QNetworkReply *reply = manager->post(request, body);

    reply->setProperty("newRoom", newRoom);

    connect(reply, &QNetworkReply::uploadProgress, this, &BackEnd::uploadingProgress);
}

void BackEnd::directMessageFinished(QNetworkReply *reply)
{
    QString response = reply->readAll();
    if (!response.isEmpty())
        emit directMessageSuccessful(reply->property("newRoom").toBool(), response.toInt());
    else
        emit submitFailed();
}

void BackEnd::blockDirectMessage(int roomId, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "chat/block/" + QString::number(roomId)));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::blockedDirectMessage);
    manager->get(request);
}

void BackEnd::getDirectMessageInfo(int postId, int commentId, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "chat/roominfo/" + QString::number(postId) + "/" + QString::number(commentId)));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedGettingDirectMessageInfo);
    manager->get(request);
}

void BackEnd::finishedGettingDirectMessageInfo(QNetworkReply *reply)
{
    QString response = reply->readAll();
    QJsonObject jsonResponse = QJsonDocument::fromJson(response.toUtf8()).object();
    emit directMessageInfo((reply->error() == QNetworkReply::NoError), jsonResponse["id"].toInt(), jsonResponse["oneVn"].toString(),
            jsonResponse["oneColor"].toString(), jsonResponse["twoVn"].toString(), jsonResponse["twoColor"].toString());
}

void BackEnd::checkNotificationsBackground(QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "user/info"));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedCheckingNotificationsBackground);
    manager->get(request);
}

void BackEnd::finishedCheckingNotificationsBackground(QNetworkReply *reply)
{
    QString response = reply->readAll();
    QJsonValue obj = QJsonDocument::fromJson(response.toUtf8()).array().first().toObject();

    int directMessages = obj["msgs"].toInt();
    if (directMessages > 0 && userSettings["dmNotifications"].toBool())
    {
        QNetworkAccessManager *managerDms = new QNetworkAccessManager(this);
        QNetworkRequest requestDms;
        requestDms.setUrl(QUrl(host + "chat/rooms/0"));
        requestDms.setRawHeader("token", userToken.toUtf8());
        connect(managerDms, &QNetworkAccessManager::finished, this, &BackEnd::finishedCheckingDirectMessageNotificationsBackground);
        managerDms->get(requestDms);
    }
    else
        emit unseenMessagesCounted(directMessages);

    int comments = obj["notifs"].toInt();
    if (comments > 0 && userSettings["commentNotifications"].toBool())
    {
        QNetworkAccessManager *managerComments = new QNetworkAccessManager(this);
        QNetworkRequest requestComments;
        requestComments.setUrl(QUrl(host + "notif/desc/0"));
        requestComments.setRawHeader("token", userToken.toUtf8());
        connect(managerComments, &QNetworkAccessManager::finished, this, &BackEnd::finishedCheckingCommentsBackground);
        managerComments->get(requestComments);
    }
    else
        emit newCommentsCounted(comments);
}

void BackEnd::finishedCheckingDirectMessageNotificationsBackground(QNetworkReply *reply)
{
    QString response = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(response.toUtf8());
    QJsonArray jsonArray = jsonDoc.array();

    int unseenMessages = 0;
    foreach (const QJsonValue &value, jsonArray)
    {
        QJsonObject obj = value.toObject();

        if (!obj["seen"].toBool())
            unseenMessages++;

        if (!obj["sent"].toBool())
        {
            int roomId = obj["id"].toInt();
            int yourId = obj["yourId"].toInt();
            QString oneVn = obj["oneVn"].toString();
            QString twoVn = obj["twoVn"].toString();
            QRegularExpression regex("[A-Z][a-z]+");
            QString animalNounOne = regex.globalMatch((yourId == 2 ? oneVn : twoVn), 1).next().captured(0);
            QString animalNounTwo = regex.globalMatch((yourId == 1 ? oneVn : twoVn), 1).next().captured(0);

            makeDmNotification(roomId, yourId, obj["postId"].toInt(), obj["lastMsg"].toString(), oneVn, obj["oneColor"].toString(), avatars[animalNounOne], twoVn, obj["twoColor"].toString(), avatars[animalNounTwo]);
        }
    }

    emit unseenMessagesCounted(unseenMessages);
}

void BackEnd::finishedCheckingCommentsBackground(QNetworkReply *reply)
{
    QString response = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(response.toUtf8());
    QJsonArray jsonArray = jsonDoc.array();

    int comments = 0;
    foreach (const QJsonValue &value, jsonArray)
    {
        QJsonObject obj = value.toObject();

        if (!obj["seen"].toBool())
        {
            comments++;

        #ifdef Q_OS_ANDROID

            QAndroidJniObject javaCommentVn = QAndroidJniObject::fromString(obj["commentVn"].toString());
            QAndroidJniObject javaPostContent = QAndroidJniObject::fromString(obj["postContent"].toString());
            QAndroidJniObject::callStaticMethod<void>("org/sien/qfandid/Backend", "makeCommentNotification",
                "(Landroid/content/Context;ILjava/lang/String;ZLjava/lang/String;)V", QtAndroid::androidContext().object(), obj["postId"].toInt(), javaCommentVn.object<jstring>(), obj["own"].toBool(), javaPostContent.object<jstring>());

        #else

            makeNotification(obj["commentVn"].toString() + " commented on " + (obj["own"].toBool() ? "your post" : "the post"), obj["postContent"].toString());

        #endif

        }
    }
    emit newCommentsCounted(comments);
}

void BackEnd::startSystemTrayIcon()
{
    trayIcon.setIcon(QIcon(":/Assets/Images/icon.png"));
    trayIcon.setToolTip("qFandid");
    trayIcon.setVisible(true);
}

void BackEnd::fetchUserInfo(QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "user/info"));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedFetchingUserInfo);
    manager->get(request);
}

void BackEnd::finishedFetchingUserInfo(QNetworkReply *reply)
{
    QString response = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(response.toUtf8());
    QJsonObject jsonObj = jsonDoc.array().first().toObject();

    QVariantMap userInfo;
    userInfo.insert("power", jsonObj["power"].toInt());
    userInfo.insert("points", jsonObj["points"].toInt());
    userInfo.insert("groups", jsonObj["groups"].toInt());
    userInfo.insert("posts", jsonObj["posts"].toInt());
    userInfo.insert("comments", jsonObj["comments"].toInt());
    userInfo.insert("riskLevel", jsonObj["riskLevel"].toInt());

    emit sendUserInfo(userInfo);
}

void BackEnd::saveUserSettings(QVariantMap userSettings)
{
    this->userSettings = userSettings;

    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "qFandid", "qFandid");
    settings.beginGroup("Settings");

    settings.setValue("loadImagesOnlyInPostPage", userSettings["loadImagesOnlyInPostPage"]);
    settings.setValue("doNotHideNsfw", userSettings["doNotHideNsfw"]);
    settings.setValue("postFontSize", userSettings["postFontSize"]);
    settings.setValue("commentFontSize", userSettings["commentFontSize"]);
    settings.setValue("scrollBarToLeft", userSettings["scrollBarToLeft"]);

    //Light mode is handled separately to prevent potential crashes
    //settings.setValue("lightMode", userSettings["lightMode"]);

    settings.setValue("newPostStyle", userSettings["newPostStyle"]);
    settings.setValue("dmNotifications", userSettings["dmNotifications"]);
    settings.setValue("commentNotifications", userSettings["commentNotifications"]);

    settings.endGroup();
}

void BackEnd::setLightMode(bool enabled)
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "qFandid", "qFandid");
    settings.setValue("Settings/lightMode", enabled);
}

QVariantMap BackEnd::fetchUserSettings()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "qFandid", "qFandid");
    settings.beginGroup("Settings");

    userSettings.insert("loadImagesOnlyInPostPage", settings.value("loadImagesOnlyInPostPage", false).toBool());
    userSettings.insert("doNotHideNsfw", settings.value("doNotHideNsfw", false).toBool());
    userSettings.insert("postFontSize", settings.value("postFontSize", 18).toInt());
    userSettings.insert("commentFontSize", settings.value("commentFontSize", 13).toInt());
    userSettings.insert("scrollBarToLeft", settings.value("scrollBarToLeft", false).toBool());
    userSettings.insert("lightMode", settings.value("lightMode", false).toBool());
    userSettings.insert("newPostStyle", settings.value("newPostStyle", false).toBool());
    userSettings.insert("dmNotifications", settings.value("dmNotifications", true).toBool());
    userSettings.insert("commentNotifications", settings.value("commentNotifications", false).toBool());

    settings.endGroup();

    return userSettings;
}

void BackEnd::setNsfw(int nsfw, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "user/setrisk/" + QString::number(nsfw)));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedFetchingUserInfo);
    manager->get(request);
}

void BackEnd::logout()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "qFandid", "qFandid");
    settings.beginGroup("Authentication");
    settings.remove("");
    settings.endGroup();
}

void BackEnd::modAction(QString action, int type, int id, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "mod/" + action + (type == 0 ? "/post/" : "/cmnt/") + QString::number(id)));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::postOrCommentRemoved);
    manager->get(request);

    #if defined Q_OS_ANDROID || defined Q_OS_IOS
    makeNotification("Removed", (type == 0 ? "Post " : "Comment ") + action);
    #endif
}

QString BackEnd::getCacheSize()
{
    QDirIterator iterator(cacheDir, QDir::Files);
    qint64 total = 0;
    while (iterator.hasNext())
    {
        QFileInfo file(iterator.next());
        total += file.size();
    }

    return QString::number((float)total / 1024 / 1024, 'f', 2) + " MB";
}

void BackEnd::clearCache()
{
    QDirIterator iterator(cacheDir, QDir::Files);
    while (iterator.hasNext())
        QFile::remove(iterator.next());
}

void BackEnd::modJoinGroups(QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "mod/join"));
    request.setRawHeader("token", userToken.toUtf8());
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::finishedFetchingUserInfo);
    manager->get(request);
    makeNotification("Joined", "Joined all groups");
}

void BackEnd::createGroup(QString name, QString description, bool nsfw, QString userToken)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + "group/create"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("token", userToken.toUtf8());

    QJsonObject groupData;
    groupData["name"] = name;
    groupData["description"] = description;
    groupData["riskLevel"] = QString::number((int)nsfw);

    QJsonDocument doc(groupData);
    QByteArray body = doc.toJson();

    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::groupCreated);
    manager->post(request, body);
}

void BackEnd::restartProgram()
{
    qApp->quit();

    #if !defined Q_OS_ANDROID && !defined Q_OS_IOS
    QProcess::startDetached(qApp->arguments()[0], qApp->arguments());
    #endif
}

void BackEnd::resetSkipId()
{
    skipId = 0;
}

void BackEnd::checkAppVersion(QString appVersion)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(versionSource));
    connect(manager, &QNetworkAccessManager::finished, this, &BackEnd::receivedUpdateCheck);
    QNetworkReply *reply = manager->get(request);
    reply->setProperty("appVersion", appVersion);
}

void BackEnd::receivedUpdateCheck(QNetworkReply *reply)
{
    QString latestVersion = reply->readAll();
    if (!latestVersion.isEmpty() && reply->property("appVersion").toString().compare(latestVersion) != 0)
        makeMessageNotification(latestVersion + " update available", "Get it from https://fandid.app");
}

void BackEnd::makeMessageNotification(QString title, QString message)
{
    #ifdef Q_OS_ANDROID

    QAndroidJniObject javaTitle = QAndroidJniObject::fromString(title);
    QAndroidJniObject javaMessage = QAndroidJniObject::fromString(message);
    QAndroidJniObject::callStaticMethod<void>("org/sien/qfandid/Backend", "makeMessageNotification", "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V",
                                              QtAndroid::androidContext().object(), javaTitle.object<jstring>(), javaMessage.object<jstring>());

    #else

    makeNotification(title, message);

    #endif
}

QString BackEnd::readText(QString path)
{
    QFile file(path);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream text(&file);
        return text.readAll();
    }
    else
        return QString();
}

QString BackEnd::registerAccount(QString username, QString password, QString token, bool rememberMe)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(host + (username.isEmpty() || password.isEmpty() ? "user/skip" : "user/create")));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject accountData;
    accountData["username"] = username;
    accountData["password"] = password;
    accountData["token"] = token;
    accountData["agree"] = "agree";
    accountData["type"] = registerType;

    QJsonDocument doc(accountData);
    QByteArray body = doc.toJson();

    QNetworkReply *reply = manager->post(request, body);

    QEventLoop eventLoop;
    connect(reply, SIGNAL(finished()), &eventLoop, SLOT(quit()));

    eventLoop.exec();

    QString response = reply->readAll();
    if (reply->error() != QNetworkReply::NoError || response.isEmpty())
        return QString();
    else
    {
        if (rememberMe)
        {
            QSettings settings(QSettings::IniFormat, QSettings::UserScope, "qFandid", "qFandid");
            settings.beginGroup("Authentication");
            settings.setValue("userToken", response);
            settings.endGroup();
        }

        return response;
    }
}

void BackEnd::copyTextToClipboard(QString text)
{
    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(unescapeText(text));

    #ifdef Q_OS_ANDROID
    makeNotification("", "Copied to clipboard");
    #endif
}
