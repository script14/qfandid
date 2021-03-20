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
//import RequestType 1.0 //A shared enumeration between QML and C++
import QtQuick.Controls.Material 2.12
import 'Assets/Strings/mystrings.js' as MyStrings

ApplicationWindow {
    id: window
    width: 720
    height: 1280
    visible: true
    color: globalBackground
    title: qsTr("qFandid")
    Material.theme: Material.Dark

    //Global persistent QML variables
    //These have to be stored here so they can be accessed from any instance of any component
    property var userInfo: {"power": 0, "points": 0, "groups": 0, "posts": 0, "comments": 0, "riskLevel": 0}
    property var userSettings: {"loadImagesOnlyInPostPage": false, "doNotHideNsfw": false, "postFontSize": 18, "commentFontSize": 13, "scrollBarToLeft": false}
    property string cacheDir: globalBackend.getCacheDir();
    property string userToken: ""
    property bool platformIsMobile: Qt.platform.os == "android" || Qt.platform.os == "ios"
    property bool desktopIsFullscreen: (window.visibility === 4 || window.visibility === 5) && !platformIsMobile //4 is Maximized, 5 is FullScreen
    property int messageCheckInterval: 10000 //Milliseconds

    //Links
    property string linkRules: "https://fandid.app/rules.html"
    property string linkWebsite: "https://fandid.app"

    //Colors
    property color fandidYellow: "#FFC20B"
    property color fandidYellowDarker: "#DBA100"
    property color darkenedButton: "#505050"
    property color globalBackground: "#333333"
    property color globalBackgroundDarker: Qt.darker(globalBackground, 1.4)
    property color globalTextColor: "#E0E0E0"
    property color globalTextColorDarker: Qt.darker(globalTextColor, 1.5)
    property color notificationRed: "#DB0B00"

    //Font icons
    property string ic_arrow_down: "\ue930"
    property string ic_bell: "\ue931"
    property string ic_camera: "\ue932"
    property string ic_chat: "\ue933"
    property string ic_comment: "\ue934"
    property string ic_create: "\ue935"
    property string ic_cross: "\ue936"
    property string ic_email: "\ue937"
    property string ic_groups: "\ue938"
    property string ic_hate: "\ue939"
    property string ic_home: "\ue93a"
    property string ic_love: "\ue93b"
    property string ic_profile: "\ue93c"
    property string ic_rightarrow: "\ue93d"
    property string ic_send: "\ue93e"
    property string ic_settings: "\ue93f"
    property string ic_stat_logo: "\ue940"

    BackEnd {
        id: globalBackend
    }

    //Store a pointer to the QML instance where the UI resides so it can be accessed from static C++ class methods
    //such as callback C++ functions that are called from Java
    Component.onCompleted:
    {
        globalBackend.storeQmlInstance()
        //console.debug(test["test"])
        globalBackend.checkAppVersion(MyStrings.appVersion)
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
        focus: true
        signal preloadPostCreator(int groupId, string groupName, string text, bool nsfw)

        Keys.onEscapePressed: if (mainStackView.depth > 1)
                                  mainStackView.pop()
    }

    FontLoader {
        source: "Assets/Font/FandidIcons.ttf"
    }

    function launchMainView()
    {
        if (Qt.platform.os == "android")
            ;//globalBackend.registerJavaCallbacks()
        else
        {
            globalBackend.startSystemTrayIcon()
        }

        globalBackend.checkNotificationsBackground(userToken)

        mainView.active = true
        mainStackView.replace(mainView)

        globalBackend.fetchUserInfo(userToken)
        userSettings = globalBackend.fetchUserSettings()
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
