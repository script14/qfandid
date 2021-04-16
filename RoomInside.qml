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
import qFandid.Backend 1.0
import QtQuick.Layouts 1.0
import RequestType 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.12

Item {
    id: roomInside

    property int roomId: 0
    property int postId: 0
    property int commentId: 0
    property int yourId: 0
    property string oneAvatar: ""
    property string oneVn: "ExuberantRaptor"
    property color oneColor: "blue"
    property string twoAvatar: ""
    property string twoVn: "TrickyPig"
    property color twoColor: "gray"

    property bool newRoom: false

    property int sourceButtonSize: 35
    property int textCharLimit: 1000

    property int targetAvatarSize: platformIsMobile ? 25 : 30

    property string targetAvatar: yourId == 2 ? oneAvatar : twoAvatar
    property color targetColor: yourId == 2 ? oneColor : twoColor
    property color yourColor: yourId == 2 ? twoColor : oneColor
    property string targetName: yourId == 2 ? oneVn : twoVn

    BackEnd {
        id: roomInsideBackend
    }

    Component.onCompleted:
    {
        checkDirectMessageInfo()
        messageNotificationTimer.running = false
        if (platformIsMobile)
            globalBackend.cancelActiveNotification(roomId)
    }

    Component.onDestruction:
    {
        focusWindow.focus = true
        messageNotificationTimer.running = true
    }

    Connections {
        target: globalBackend
        function onSendSharedTextToQML(sharedText)
        {
            roomInsideTextArea.text += sharedText
        }
        function onSendSharedImageToQML(path)
        {
            if (path.length > 0)
                setImage("file:/" + path)
        }
    }

    Rectangle {
        id: roomInsideTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: roomInsideTitle.height + 20
        color: globalBackgroundDarker
        z: 1

        Label {
            id: backButton
            text: ic_arrow_down
            color: globalTextColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 20
            rotation: 90
            renderType: Text.NativeRendering
            font.family: "FandidIcons"
            font.pointSize: 25

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mainStackView.pop()
            }
        }

        RowLayout {
            id: roomInsideTitle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Label {
                text: targetAvatar
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: targetColor
                font.family: "FandidIcons"
                font.pointSize: targetAvatarSize
                renderType: Text.NativeRendering

                Rectangle {
                    radius: 100
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.contentWidth - 2
                    height: parent.contentHeight - 2
                    color: userSettings["lightMode"] && targetName === "Mod" ? globalBackground : avatarBackgroundColor
                    z: -1
                }

            }

            Label {
                width: window.width / 2
                text: targetName
                color: targetColor
                font.pointSize: 20
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                renderType: Text.NativeRendering
            }
        }

        Button {
            id: sourceButton
            text: ic_rightarrow
            font.family: "FandidIcons"
            font.pointSize: sourceButtonSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            z: 1

            background: Rectangle {
                id: sourceButtonBackground
                implicitWidth: sourceButtonText.contentWidth
                implicitHeight: sourceButtonText.contentHeight
                color: "transparent"
            }

            contentItem: Text {
                id: sourceButtonText
                text: parent.text
                font: parent.font
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: parent.down ? Qt.darker(targetColor, 1.5) : targetColor
            }

            onClicked:
            {
                mainStackView.push("CommentsPage.qml", {"postId": postId})
                focusWindow.focus = true
            }
        }
    }

    Loader {
        id: chatMessagesLoader
        anchors.top: roomInsideTopBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: roomInsideCreatorBody.top
        anchors.leftMargin: 5
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        active: true
        sourceComponent: ChatMessageFeed {
            id: commentsMultiModel
            roomId: roomInside.roomId
            newRoom: roomInside.newRoom
        }
    }

    Rectangle {
        id: roomInsideCreatorBody
        width: window.width
        height: scrollView.contentHeight < window.height / 5 ? scrollView.contentHeight + 20 : window.height / 5
        color: globalBackgroundDarker
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        RowLayout {
            id: roomInsideCreatorRowLayout

            anchors.fill: parent
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            spacing: 10

            Label {
                id: upload
                text: ic_camera
                Layout.bottomMargin: 5
                Layout.fillHeight: false
                font.pointSize: 30
                font.family: "FandidIcons"
                renderType: Text.NativeRendering
                color: globalTextColor

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        if (Qt.platform.os == "android")
                        {
                            roomInsideBackend.androidRequestStoragePermission()
                            if (!roomInsideBackend.androidCheckStoragePermission())
                            {
                                globalBackend.makeNotification("", "You must grant storage permission to upload images")
                                return
                            }
                        }

                        fileDialog.open()
                    }
                }

                Image {
                    id: imageToUpload
                    visible: false
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.height: parent.contentHeight
                    sourceSize.width: parent.contentWidth
                }
            }

            ScrollView {
                id: scrollView
                Layout.maximumHeight: window.height / 6
                Layout.fillWidth: true
                Layout.fillHeight: false

                TextArea {
                    id: roomInsideTextArea
                    placeholderText: "Write a private message"
                    font.pointSize: 15
                    selectByKeyboard: true
                    selectByMouse: platformIsMobile ? false : true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    renderType: Text.NativeRendering
                    Material.accent: fandidYellowDarker
                    bottomPadding: platformIsMobile ? 5 : 10

                    background: Rectangle {
                        implicitWidth: scrollView.width
                        implicitHeight: roomInsideTextArea.contentHeight
                        color: globalBackground
                        radius: 10
                    }

                    onTextChanged:
                    {
                        if (length > textCharLimit)
                            remove(textCharLimit, length)
                        charLimit.text = length + "/" + textCharLimit
                    }

                    onEditingFinished: focusWindow.focus = true

                    Keys.onPressed:
                    {
                        if (!platformIsMobile && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !(event.modifiers & Qt.ShiftModifier))
                            sendMessage()
                        else if (event.key === Qt.Key_Escape)
                            focusWindow.focus = true
                    }
                }
            }

            Label {
                id: charLimit
                text: "0/" + textCharLimit
                renderType: Text.NativeRendering
                color: globalTextColor
                font.pointSize: 12
            }

            RoundButton {
                id: sendButton
                height: implicitContentHeight + 20
                text: ic_send
                font.family: "FandidIcons"
                font.bold: true
                font.pointSize: 15
                font.capitalization: Font.MixedCase
                Material.background: fandidYellowDarker
                Material.foreground: buttonColor

                onPressed: sendMessage()

                MyBusyIndicator {
                    id: myBusyIndicator
                    indicatorWidth: 50
                    indicatorHeight: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    visible: false
                }
            }
        }
    }

    function sendMessage()
    {
        roomInsideTextArea.enabled = false
        sendButton.enabled = false
        focusWindow.focus = true
        roomInsideBackend.sendDirectMessage(roomId, postId, commentId, roomInsideTextArea.text, newRoom, userToken)
    }

    Connections {
        target: roomInsideBackend

        function onDirectMessageInfo(exists, roomId, oneVn, oneColor, twoVn, twoColor)
        {
            if (exists)
            {
                roomInside.roomId = roomId
                roomInside.oneVn = oneVn
                roomInside.oneColor = oneColor
                roomInside.twoVn = twoVn
                roomInside.twoColor = twoColor
                roomInside.newRoom = false
                chatMessagesLoader.active = false
                chatMessagesLoader.active = true
            }
        }

        function onUploadProgress(progress)
        {
            if (progress != "100")
                sendButton.text = progress + "%"
            else
            {
                sendButton.text = ic_send
                myBusyIndicator.visible = true
            }
        }

        function onSubmitFailed()
        {
            restoreState()
            globalBackend.makeNotification("Message failed", "Failed to submit message")
        }

        function onDirectMessageSuccessful(newRoom, replyId)
        {
            restoreState()
            roomInsideTextArea.clear()
            removeImage()

            if (!platformIsMobile)
                roomInsideTextArea.forceActiveFocus()

            if (newRoom)
                checkDirectMessageInfo()
        }
    }

    function checkDirectMessageInfo()
    {
        if (newRoom)
            roomInsideBackend.getDirectMessageInfo(postId, commentId, userToken)
    }

    function restoreState()
    {
        roomInsideTextArea.enabled = true
        sendButton.enabled = true
        sendButton.text = ic_send
        myBusyIndicator.visible = false
    }

    function setImage(fileUrl)
    {
        if (roomInsideBackend.prepareImage(fileUrl))
        {
            imageToUpload.source = Qt.resolvedUrl(fileUrl)
            imageToUpload.visible = true
            upload.color = globalBackgroundDarker
        }
        else
        {
            removeImage()
            globalBackend.makeNotification("Warning", "Image file size is too high")
        }
    }

    function removeImage()
    {
        imageToUpload.visible = false
        upload.color = globalTextColor
        roomInsideBackend.cancelImage()
    }

    FileDialog {
        id: fileDialog
        title: "Choose an image"
        nameFilters: [ "Image files (*.jpg *.jpeg *.png *.tiff *.tif *.webp *.gif)" ]
        onAccepted: setImage(fileUrl)
        onRejected: removeImage()
    }

    Label {
        id: dragAndDropLabel
        z: 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("Drop file here")
        font.pointSize: 40
        color: fandidYellow
        visible: false
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onEntered: {
            window.color = globalBackgroundDragAndDrop
            dragAndDropLabel.visible = true
        }

        onExited: {
            window.color = globalBackground
            dragAndDropLabel.visible = false
        }

        onDropped: {
            window.color = globalBackground
            dragAndDropLabel.visible = false

            if (!drop.urls[0].endsWith(".jpg") && !drop.urls[0].endsWith(".jpeg") && !drop.urls[0].endsWith(".png")
                    && !drop.urls[0].endsWith(".tiff") && !drop.urls[0].endsWith(".tif") && !drop.urls[0].endsWith(".webp") && !drop.urls[0].endsWith(".gif"))
                globalBackend.makeNotification("Invalid file", "You cannot upload this type of file")
            else
                setImage(drop.urls[0])
        }
    }
}
