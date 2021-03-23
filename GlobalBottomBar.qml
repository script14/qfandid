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

import QtQuick 2.4
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.12

Item {

    //Variables
    property string homeText: "Home"
    property string groupsText: "Groups"
    property string chatText: "Chat"
    property string meText: "Me"

    property alias globalBottomBarheight: bottomBar.height
    property int iconSize: platformIsMobile ? 22 : 25
    property int textSize: 15
    property int buttonPadding: 5
    property int postButtonTextSize: textSize * (platformIsMobile ? 3 : 2.5)

    property color selected: fandidYellowDarker
    property color deselected: globalTextColorDarker

    //Functions
    function colorButton(index)
    {
        switch(index)
        {
        case 0:
            homeButtonContentItem.color = selected
            groupButtonContentItem.color = deselected
            chatButtonContentItem.color = chatButtonContentItem.color === notificationRed ? chatButtonContentItem.color : deselected
            meButtonContentItem.color = meButtonContentItem.color === notificationRed ? meButtonContentItem.color : deselected
            break
        case 1:
            homeButtonContentItem.color = deselected
            groupButtonContentItem.color = selected
            chatButtonContentItem.color = chatButtonContentItem.color === notificationRed ? chatButtonContentItem.color : deselected
            meButtonContentItem.color = meButtonContentItem.color === notificationRed ? meButtonContentItem.color : deselected
            break
        case 2:
            homeButtonContentItem.color = deselected
            groupButtonContentItem.color = deselected
            chatButtonContentItem.color = selected
            meButtonContentItem.color = meButtonContentItem.color === notificationRed ? meButtonContentItem.color : deselected
            chatText = "Chat"
            break
        case 3:
            homeButtonContentItem.color = deselected
            groupButtonContentItem.color = deselected
            chatButtonContentItem.color = chatButtonContentItem.color === notificationRed ? chatButtonContentItem.color : deselected
            meButtonContentItem.color = selected
            meText = "Me"
            globalBackend.fetchUserInfo(userToken)
            break
        }
    }

    Rectangle {
        id: bottomBar
        height: homeButton.height
        color: globalBackgroundDarker
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        RoundButton {
            id: postButton
            width: height
            height: bottomBar.height + 20
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: ic_create
            font.family: "FandidIcons"
            font.pointSize: postButtonTextSize
            Material.background: "#5d5d5d"
            background.anchors.fill: this
            padding: buttonPadding
            onClicked: mainStackView.push("PostCreator.qml")

            contentItem: Text {
                id: postButtonText
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: globalBackgroundDarker
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            id: bottomBarLeftRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: postButton.left
            anchors.bottom: parent.bottom
            spacing: 0

            Button {
                id: homeButton
                text: "<span style=font-size:" + iconSize + "pt>" + ic_home + "</span><br><span style=font-size:" + textSize + "pt>" + homeText + "</span>"
                flat: true
                display: AbstractButton.TextOnly
                font.family: "FandidIcons"
                Layout.fillWidth: true
                font.capitalization: Font.MixedCase
                background.anchors.fill: this
                padding: buttonPadding

                contentItem: Text {
                    id: homeButtonContentItem
                    textFormat: Text.RichText
                    text: parent.text
                    font: parent.font
                    color: selected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked:
                {
                    if (swipeViewMain.currentIndex === 0)
                        homePage.movePostFeedToBeginning()
                    else
                        swipeViewMain.setCurrentIndex(0)
                }
            }

            Button {
                id: groupButton
                text: "<span style=font-size:" + iconSize + "pt>" + ic_groups + "</span><br><span style=font-size:" + textSize + "pt>" + groupsText + "</span>"
                flat: true
                display: AbstractButton.TextOnly
                font.family: "FandidIcons"
                Layout.fillWidth: true
                font.capitalization: Font.MixedCase
                background.anchors.fill: this
                padding: buttonPadding

                contentItem: Text {
                    id: groupButtonContentItem
                    textFormat: Text.RichText
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked:
                {
                    if (swipeViewMain.currentIndex === 1)
                    {
                        groupPageLoader.active = false
                        groupPageLoader.active = true
                    }

                    else
                        swipeViewMain.setCurrentIndex(1)
                }
            }
        }

        RowLayout {
            id: bottomBarRightRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: postButton.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 0

            Button {
                id: chatButton
                text: "<span style=font-size:" + iconSize + "pt>" + ic_chat + "</span><br><span style=font-size:" + textSize + "pt>" + chatText + "</span>"
                flat: true
                display: AbstractButton.TextOnly
                font.family: "FandidIcons"
                Layout.fillWidth: true
                font.capitalization: Font.MixedCase
                background.anchors.fill: this
                padding: buttonPadding

                contentItem: Text {
                    id: chatButtonContentItem
                    textFormat: Text.RichText
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked:
                {
                    if (swipeViewMain.currentIndex === 2)
                        chatPageLoader.item.movePostFeedToBeginning()
                    else
                        swipeViewMain.setCurrentIndex(2)
                }
            }

            Button {
                id: meButton
                text: "<span style=font-size:" + iconSize + "pt>" + ic_profile + "</span><br><span style=font-size:" + textSize + "pt>" + meText + "</span>"
                flat: true
                display: AbstractButton.TextOnly
                font.family: "FandidIcons"
                Layout.fillWidth: true
                font.capitalization: Font.MixedCase
                background.anchors.fill: this
                padding: buttonPadding

                contentItem: Text {
                    id: meButtonContentItem
                    textFormat: Text.RichText
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked:
                {
                    if (swipeViewMain.currentIndex === 3)
                        mePageLoader.item.moveFeedToBeginning()
                    else
                    {
                        swipeViewMain.setCurrentIndex(3)
                        mePageLoader.item.refreshNotifications()
                    }
                }
            }
        }
    }

    Connections {
        target: globalBackend
        function onUnseenMessagesCounted(unseenMessages)
        {
            if (unseenMessages > 0)
            {
                chatText = "Chat (" + (unseenMessages === 20 ? unseenMessages + "+" : unseenMessages) + ")"
                chatButtonContentItem.color = notificationRed
            }
        }

        function onNewCommentsCounted(newComments)
        {
            if (newComments > 0 && swipeViewMain.currentIndex !== 3)
            {
                meText = "Me (" + (newComments === 30 ? newComments + "+" : newComments) + ")"
                meButtonContentItem.color = notificationRed
            }
        }
    }
}
