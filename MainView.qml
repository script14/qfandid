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

import QtQuick 2.0
import QtQuick.Controls 2.15

Item {

    SwipeView {
        id: swipeViewMain
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: globalBottomBar.top
        spacing: 20
        onCurrentIndexChanged: globalBottomBar.colorButton(currentIndex)

        property bool groupPageLoaded: false
        property bool chatPageLoaded: false
        property bool mePageLoaded: false

        Connections {
            target: globalBackend

            //This is triggered from Android intents in Java
            function onSendSharedTextToQML(sharedText)
            {
                console.debug(mainStackView.depth)
                if (mainStackView.depth === 1)
                {
                    mainStackView.push("PostCreator.qml")
                    focusWindow.preloadPostCreator(0, "", sharedText, false)
                }
            }
        }

        //Loaded by default
        HomePage{id: homePage}

        Loader {
            id: groupPageLoader
            active: swipeViewMain.currentIndex == 1 || swipeViewMain.groupPageLoaded
            sourceComponent: GroupPage{}
            onLoaded: swipeViewMain.groupPageLoaded = true
        }

        Loader {
            id: chatPageLoader
            active: swipeViewMain.currentIndex == 2 || swipeViewMain.chatPageLoaded
            sourceComponent: ChatPage{}
            onLoaded: swipeViewMain.chatPageLoaded = true
        }

        Loader {
            id: mePageLoader
            active: swipeViewMain.currentIndex == 3 || swipeViewMain.mePageLoaded
            sourceComponent: MePage{}
            onLoaded: swipeViewMain.mePageLoaded = true
        }
    }

    GlobalBottomBar {
        id: globalBottomBar
        height: globalBottomBarheight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}
