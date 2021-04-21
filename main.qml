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

import QtQuick 2.15
import QtQuick.Controls 2.15
import qFandid.Backend 1.0 //The C++ globalBackend whose name & version are defined in the .pro file
import QtQuick.Controls.Material 2.12
import 'Assets/Strings/mystrings.js' as MyStrings

ApplicationWindow {
    id: window
    width: 720
    height: 1280
    visible: true
    color: globalBackground
    title: qsTr("qFandid")
    Material.theme: userSettings["lightMode"] ? Material.Light : Material.Dark

    //Global persistent QML variables
    //These have to be stored here so they can be accessed from any instance of any component
    property var userInfo: {"power": 0, "points": 0, "groups": 0, "posts": 0, "comments": 0, "riskLevel": 0}
    property var userSettings: {"loadImagesOnlyInPostPage": false, "doNotHideNsfw": false, "postFontSize": 18, "commentFontSize": 13,
        "scrollBarToLeft": false, "lightMode": false, "minimalPostStyle": false, "dmNotifications": true, "commentNotifications": false, "windowWidth": 720, "windowHeight": 1280}
    property string cacheDir: globalBackend.getCacheDir();
    property string userToken: ""
    property bool platformIsMobile: Qt.platform.os == "android" || Qt.platform.os == "ios"
    property bool desktopIsFullscreen: (window.visibility === 4 || window.visibility === 5) && !platformIsMobile //4 is Maximized, 5 is FullScreen
    property int messageCheckInterval: 10000 //Milliseconds

    //Links
    property string linkRules: "https://fandid.app/rules.html"
    property string linkWebsite: "https://fandid.app"
    property string linkRecaptcha: "https://fandid.app/captcha.html"

    //Colors
    property color fandidYellow: userSettings["lightMode"] ? "#FFBB00" : "#FFC20B"
    property color fandidYellowDarker: userSettings["lightMode"] ? "#FFBB00" : "#DBA100"
    property color darkenedButton: "#505050"
    property color globalBackground: userSettings["lightMode"] ? "#F4F5FA" : "#333333"
    property color globalBackgroundDarker: Qt.darker(globalBackground, userSettings["lightMode"] ? 1.1 : 1.4)
    property color globalBackgroundDragAndDrop: userSettings["lightMode"] ? Qt.darker(globalBackground, 1.5) : Qt.lighter(globalBackground, 1.5)
    property color postToGroupEntryColor: userSettings["lightMode"] ? "white" : globalBackgroundDarker
    property color postToGroupEntryBorderColor: userSettings["lightMode"] ? globalBackgroundDarker : "#414141"
    property color globalTextColor: userSettings["lightMode"] ? "#4D4D4D" : "#E0E0E0"
    property color globalTextColorDarker: userSettings["lightMode"] ? "#9D9D9F" : Qt.darker(globalTextColor, 1.5)
    property color topBarIndicatorDeselectedColor: userSettings["lightMode"] ? globalTextColor : globalTextColorDarker
    property color avatarBackgroundColor: userSettings["lightMode"] ? "black" : globalBackground
    property color commentIconColor: userSettings["lightMode"] ? globalTextColorDarker : globalTextColor
    property color whiteTextColor: "#E0E0E0"
    property color highlightColor: globalBackgroundDarker
    property color postCircleColor: userSettings["lightMode"] ? "#DCDDE2" : "#5d5d5d"
    property color postCircleTextColor: userSettings["lightMode"] ? "#777779" : globalBackgroundDarker
    property color commentIndicatorColor: userSettings["lightMode"] ? globalBackgroundDarker : globalTextColor
    property color buttonColor: userSettings["lightMode"] ? "white" : globalTextColor
    property color notificationRed: userSettings["lightMode"] ? "red" : "#DB0B00"
    property color newPostColor: userSettings["lightMode"] ? Qt.darker(globalBackground, 1.1) : Qt.lighter(globalBackground, 1.2)

    //Font icons
    property string ic_arrow_down: "\ue931"
    property string ic_bell: "\ue932"
    property string ic_camera: "\ue933"
    property string ic_chat: "\ue934"
    property string ic_comment: "\ue935"
    property string ic_create: "\ue936"
    property string ic_cross: "\ue937"
    property string ic_email: "\ue938"
    property string ic_groups: "\ue939"
    property string ic_hate: "\ue93a"
    property string ic_home: "\ue93b"
    property string ic_love: "\ue93c"
    property string ic_profile: "\ue93d"
    property string ic_rightarrow: "\ue93e"
    property string ic_send: "\ue93f"
    property string ic_settings: "\ue940"
    property string ic_stat_logo: "\ue941"

    BackEnd {
        id: globalBackend
    }

    //Store a pointer to the QML instance where the UI resides so it can be accessed from static C++ class methods
    //such as callback C++ functions that are called from Java
    Component.onCompleted:
    {
        globalBackend.storeQmlInstance()
        userSettings = globalBackend.fetchUserSettings()
        globalBackend.checkAppVersion(MyStrings.appVersion)

        if (!platformIsMobile)
        {
            window.width = userSettings["windowWidth"]
            window.height = userSettings["windowHeight"]
        }
    }

    Component.onDestruction:
    {
        if (!platformIsMobile)
            globalBackend.saveWindowProperties(window.width, window.height)
    }

    Connections {
        target: globalBackend
        function onSendUserInfo(userInfo)
        {
            window.userInfo = userInfo
        }

        function onOpenDirectMessageFromNotification(roomId, yourId, postId, oneVn, oneColor, oneAvatar, twoVn, twoColor, twoAvatar)
        {
            mainStackView.push("RoomInside.qml", {"roomId": roomId, "postId": postId, "yourId": yourId, "oneAvatar": oneAvatar, "oneVn": oneVn, "oneColor": oneColor, "twoAvatar": twoAvatar, "twoVn": twoVn, "twoColor": twoColor})
        }

        function onOpenPostFromNotification(postId, notificationId)
        {
            mainStackView.push("CommentsPage.qml", {"postId": postId, "notificationId": notificationId})
        }
    }

    onClosing:
    {
        if (mainStackView.depth > 1 && platformIsMobile)
        {
            //This is to capture the back button on mobile
            close.accepted = false
            mainStackView.pop()
        }
        else if (mainStackView.depth == 1 && Qt.platform.os == "android")
        {
            if (!androidCloseTimer.running)
            {
                close.accepted = false
                androidCloseTimer.start()
                globalBackend.makeNotification("", "Press back again to exit")
            }
        }
    }

    Timer {
        id: androidCloseTimer
        interval: 2000
        running: false
        repeat: false
    }

    Timer {
        id: messageNotificationTimer
        interval: messageCheckInterval
        repeat: true
        running: mainView.active
        onTriggered: globalBackend.checkNotificationsBackground(userToken)
    }

    Item {
        //This is a pathway for simple signals to traverse between components that have no other relationship except being children of the main.qml component
        //It is also the main item where focus is set by default so the app can react to various keys presses from keyboards
        id: focusWindow
        visible: false
        signal preloadPostCreator(int groupId, string groupName, string text, string imagePath, bool nsfw)
        signal enableGroupPostButton()

        Keys.onBackPressed:
        {
            if (platformIsMobile)
                window.close()
        }

        Keys.onEscapePressed:
        {
            if (mainStackView.depth > 1)
                mainStackView.pop()
        }
    }

    FontLoader {
        source: "Assets/Font/FandidIcons.ttf"
    }

    function launchMainView()
    {
        if (!platformIsMobile)
            globalBackend.startSystemTrayIcon()

        globalBackend.checkNotificationsBackground(userToken)

        mainView.active = true
        mainStackView.replace(mainView)

        globalBackend.fetchUserInfo(userToken)
    }

    StackView {
        id: mainStackView
        anchors.fill: parent

        Component.onCompleted:
        {
            userToken = globalBackend.getLoginToken()

            if (userToken.length != 0)
                launchMainView()
            else
            {
                loginPage.active = true
                push(loginPage)
            }
        }

        pushEnter: Transition {
               PropertyAnimation {
                   property: "opacity"
                   from: 0
                   to: 1
                   duration: 100
               }
           }
       pushExit: Transition {
           PropertyAnimation {
               property: "opacity"
               from: 1
               to: 0
               duration: 100
           }
       }
       popEnter: Transition {
           PropertyAnimation {
               property: "opacity"
               from: 0
               to: 1
               duration: 100
           }
       }
       popExit: Transition {
           PropertyAnimation {
               property: "opacity"
               from: 1
               to: 0
               duration: 100
           }
       }
    }

    Loader {
        id: mainView
        active: false
        sourceComponent: MainView{}
    }

    Loader {
        id: loginPage
        active: false
        sourceComponent: LoginPage{}
    }
}
