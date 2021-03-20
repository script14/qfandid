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

import QtQuick 2.6
import QtQuick.Controls 2.15
import qFandid.Backend 1.0
import QtQuick.Layouts 1.0
import RequestType 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.12

Item {
    id: postCreator

    property int groupId: 0

    property int textCharLimit: 8000

    BackEnd {
        id: postCreatorBackend
    }

    Connections {
        target: globalBackend
        function onSendSharedTextToQML(sharedText)
        {
            postTextArea.text += sharedText
        }
    }

    Component.onDestruction: focusWindow.focus = true

    Rectangle {
        id: postCreatorTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: postCreatorTitle.contentHeight + 20
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
            id: postCreatorTitle
            width: window.width / 3
            text: qsTr("Create a post")
            color: globalTextColor
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.NativeRendering
        }
    }

    Label {
        id: postGroupLabel
        anchors.top: postCreatorTopBar.bottom
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.leftMargin: 10
        text: qsTr("Post to: ")
        width: contentWidth
        font.pointSize: 20
        color: fandidYellowDarker
    }

    TextField {
        id: textField
        implicitWidth: window.width - postGroupLabel.anchors.leftMargin - postGroupLabel.contentWidth - textField.anchors.leftMargin - 10
        anchors.top: postCreatorTopBar.bottom
        anchors.left: postGroupLabel.right
        anchors.topMargin: postGroupLabel.contentHeight / 2 - contentHeight / 2 + postGroupLabel.anchors.topMargin / 2
        anchors.leftMargin: 10
        renderType: Text.NativeRendering
        placeholderText: qsTr("Type 3 characters")
        color: globalTextColor
        font.pointSize: 15
        //This is to prevent Android keyboards like Swiftkey from keeping the text until the user inputs a space because that way the textChanged signal is not emitted
        inputMethodHints: Qt.ImhSensitiveData
        Material.accent: fandidYellowDarker

//        background: Rectangle {
//            id: textFieldBackground
//            implicitWidth: window.width - postGroupLabel.anchors.leftMargin - postGroupLabel.contentWidth - textField.anchors.leftMargin - 10
//            implicitHeight: platformIsMobile ? 20 : 40
//            color: globalBackgroundDarker
//            radius: 20
//        }

        onTextChanged: loadGroups()

        onPressed:
        {
            textField.implicitWidth = window.width - postGroupLabel.anchors.leftMargin - postGroupLabel.contentWidth - textField.anchors.leftMargin - 10
            //textFieldBackground.color = globalBackgroundDarker

            loadGroups()
        }

        onFocusChanged:
        {
            if (textField.focus == false && postToGroupEntryLoader.focus == false)
                postToGroupEntryLoader.active = false
        }

        Keys.onEscapePressed:
        {
            textField.focus = false
            focusWindow.focus = true
        }

        function loadGroups()
        {
            if (textField.text.length >= 3)
            {
                postToGroupEntryLoader.active = false
                postToGroupEntryLoader.active = true
            }
            else
                postToGroupEntryLoader.active = false
        }
    }

    Loader {
        id: postToGroupEntryLoader
        active: false
        anchors.top: textField.bottom
        anchors.topMargin: 15
        height: window.height / 2
        x: postGroupLabel.anchors.leftMargin + postGroupLabel.contentWidth + textField.anchors.leftMargin
        z: 1
        sourceComponent: MultiFeed {
            type: RequestType.POSTTOGROUPENTRY
            groupSearch: textField.text
        }
    }

    Rectangle {
        id: topSeparator
        width: window.width
        height: 5
        anchors.top: textField.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        color: globalBackgroundDarker
    }

    ScrollView {
        id: scrollView
        anchors.top: topSeparator.bottom
        anchors.bottom: postBottomBar.top
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: window.width

        TextArea {
            id: postTextArea
            placeholderText: qsTr("Speak your mind freely")
            font.pointSize: 15
            selectByKeyboard: true
            selectByMouse: platformIsMobile ? false : true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            renderType: Text.NativeRendering
            leftPadding: 10
            rightPadding: 10
            Material.accent: fandidYellowDarker

            background: Rectangle {
                implicitWidth: scrollView.width
                implicitHeight: postTextArea.contentHeight
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
        }
    }

    Rectangle {
        id: postBottomBar
        width: window.width
        height: upload.contentHeight + 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: globalBackgroundDarker

        Label {
            id: upload
            text: ic_camera
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottomMargin: 10
            font.pointSize: 35
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
                        postCreatorBackend.androidRequestStoragePermission()
                        if (!postCreatorBackend.androidCheckStoragePermission())
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

        MySwitch {
            id: nsfwSwitch
            text: qsTr("NSFW")
            font.pointSize: 15
            anchors.verticalCenter: parent.verticalCenter
            rightPadding: platformIsMobile ? charLimit.contentWidth * 1.2 : undefined
            anchors.horizontalCenter: parent.horizontalCenter
            visible: userInfo["riskLevel"] > 0
        }

        Label {
            id: charLimit
            text: "0/" + textCharLimit
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: postButton.left
            anchors.rightMargin: 10
            Layout.fillWidth: true
            renderType: Text.NativeRendering
            color: globalTextColor
            font.pointSize: 15
        }

        RoundButton {
            id: postButton
            width: implicitContentWidth + 50
            height: implicitContentHeight + 20
            text: qsTr("Post")
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            font.bold: true
            font.pointSize: 18
            font.capitalization: Font.MixedCase
            Material.background: fandidYellowDarker
            enabled: groupId == 0 ? false : true

//            background: Rectangle {
//                id: postButtonBackground
//                implicitWidth: postButtonText.contentWidth + 20
//                implicitHeight: postButtonText.contentHeight
//                color: enabled ? (parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker) : darkenedButton
//                radius: 20
//            }

//            contentItem: Text {
//                id: postButtonText
//                text: parent.text
//                font: parent.font
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                color: parent.down ? Qt.darker(globalTextColor, 1.2) : globalTextColor
//            }

                onPressed:
                {
                    postTextArea.enabled = false
                    postButton.enabled = false
                    focusWindow.focus = true
                    postCreatorBackend.createPost(postTextArea.text, groupId, nsfwSwitch.checked, userToken)
                }

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

    Connections {
        target: postCreatorBackend

        function onUploadProgress(progress)
        {
            if (progress != "100")
                postButton.text = progress + "%"
            else
            {
                //postButtonText.color = globalBackgroundDarker
                //postButtonBackground.color = globalBackgroundDarker
                myBusyIndicator.visible = true
                postButton.text = "Post"
            }
        }

        function onPostFinished()
        {
            globalBackend.makeNotification("Success", "Posted successfully")
            mainStackView.pop()
        }
    }

    Connections {
        id: postCreatorPreloader
        target: focusWindow

        function onPreloadPostCreator(groupId, groupName, text, nsfw)
        {
            textField.text = groupName
            postToGroupEntryLoader.active = false
            nsfwSwitch.checked = nsfw

            if (groupName.length != 0)
            {
                textField.implicitWidth = textField.contentWidth + 20
                //textFieldBackground.color = fandidYellowDarker
            }

            postCreator.groupId = groupId

            if (text.length != 0)
                postTextArea.text = text

            postTextArea.forceActiveFocus()
        }
    }

    function removeImage()
    {
        imageToUpload.visible = false
        upload.color = globalTextColor
        postCreatorBackend.cancelImage()
    }

    FileDialog {
        id: fileDialog
        title: "Choose an image"
        //Set to remember last directory
        nameFilters: [ "Image files (*.jpg *.jpeg *.png *.tiff *.tif *.webp *.gif)" ]

        onAccepted:
        {
            console.debug(fileUrl)
            if (postCreatorBackend.prepareImage(fileUrl))
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
