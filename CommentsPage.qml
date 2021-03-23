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
    id: commentsPage

    property int postId: 0
    property int notificationId: 0
    property bool followed: false
    property var shortcutToPost: ;

    property int parentId: 0
    property int commentIndex: 0
    property string replyPrefix: ""

    property int textCharLimit: 1000

    BackEnd {
        id: commentsPageBackend
    }

    Connections {
        target: globalBackend
        function onSendSharedTextToQML(sharedText)
        {
            commentTextArea.text += sharedText
        }
    }

    Component.onDestruction: focusWindow.focus = true

    Rectangle {
        id: commentsPageTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: commentsTitle.contentHeight + 20
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

        Label {
            id: commentsTitle
            width: window.width / 3
            text: qsTr("Comments")
            color: globalTextColor
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.NativeRendering
        }

        Label {
            id: followBell
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            color: followed ? fandidYellowDarker : globalTextColor
            font.family: "FandidIcons"
            text: ic_bell
            font.pointSize: 30

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked:
                {
                    followed = !followed
                    commentsPageBackend.followPost(followed, postId, userToken)
                    focusWindow.focus = true
                }
            }
        }
    }

    MultiFeed {
        id: commentsMultiModel
        type: RequestType.COMMENTS
        postId: commentsPage.postId
        notificationId:  commentsPage.notificationId
        anchors.top: commentsPageTopBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: replyingNotifier.visible ? replyingNotifier.top : commentCreatorBody.top
        anchors.leftMargin: 5
        anchors.topMargin: 10
        anchors.bottomMargin: 10
    }

    Rectangle {
        id: replyingNotifier
        visible: false
        height: replyTarget.contentHeight + 5
        color: globalBackgroundDarker
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: commentCreatorBody.top

        Label {
            id: replyTarget
            color: globalTextColor
            text: qsTr("@ExuberantRaptor")
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 13
        }

        Label {
            id: replyCancel
            color: globalTextColor
            text: ic_cross
            font.family: "FandidIcons"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    commentIndex = parentId = 0
                    replyPrefix = ""
                    replyingNotifier.visible = false
                }
            }
        }
    }

    Rectangle {
        id: commentCreatorBody
        width: window.width
        height: scrollView.contentHeight < window.height / 5 ? scrollView.contentHeight + 20 : window.height / 5
        color: globalBackgroundDarker
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        RowLayout {
            id: commentCreatorRowLayout

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
                            commentsPageBackend.androidRequestStoragePermission()
                            if (!commentsPageBackend.androidCheckStoragePermission())
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
                    id: commentTextArea
                    placeholderText: "Write a comment"
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
                        implicitHeight: commentTextArea.contentHeight
                        color: globalBackground
                        radius: 10
                    }

                    onTextChanged:
                    {
                        if (length > textCharLimit)
                            remove(textCharLimit, length)
                        charLimit.text = length + "/" + (textCharLimit - replyPrefix.length)
                    }

                    onEditingFinished: focusWindow.focus = true

                    Keys.onPressed:
                    {
                        if (!platformIsMobile && (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) && !(event.modifiers & Qt.ShiftModifier))
                            sendComment()
                    }
                }
            }

            Label {
                id: charLimit
                text: "0/" + (textCharLimit - replyPrefix.length)
                renderType: Text.NativeRendering
                color: globalTextColor
                font.pointSize: 12
            }

            RoundButton {
                id: sendButton
                width: implicitContentWidth + 50
                height: implicitContentHeight + 20
                text: qsTr("Send")
                font.bold: true
                font.pointSize: 15
                font.capitalization: Font.MixedCase
                Material.background: fandidYellowDarker

                onPressed: sendComment()

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

    function sendComment()
    {
        if (commentTextArea.length > 0 || imageToUpload.visible)
        {
            commentTextArea.enabled = false
            sendButton.enabled = false
            focusWindow.focus = true
            commentsPageBackend.createComment(replyPrefix + commentTextArea.text, postId, parentId, userToken)
        }
    }

    Connections {
        target: commentsPageBackend

        function onUploadProgress(progress)
        {
            if (progress != "100")
                sendButton.text = progress + "%"
            else
            {
                myBusyIndicator.visible = true
                sendButton.text = "Send"
            }
        }

        function onSubmitFailed()
        {
            commentTextArea.enabled = true
            sendButton.enabled = true
            sendButton.text = "Send"
            sendButton.color = globalTextColor
            myBusyIndicator.visible = false
            globalBackend.makeNotification("Comment failed", "Failed to submit comment. Maybe you are commenting too quickly")
        }
    }

    function removeImage()
    {
        imageToUpload.visible = false
        upload.color = globalTextColor
        commentsPageBackend.cancelImage()
    }

    FileDialog {
        id: fileDialog
        title: "Choose an image"
        //Set to remember last directory
        nameFilters: [ "Image files (*.jpg *.jpeg *.png *.tiff *.tif *.webp *.gif)" ]

        onAccepted:
        {
            if (commentsPageBackend.prepareImage(fileUrl))
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

        onRejected: removeImage()
    }
}
