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
import qFandid.Backend 1.0

Item {
    id: chatMessage
    width: chatMessageBody.width
    height: chatMessageBody.height

    //API response
    property int id: 0
    property alias time: messageTime.text
    property int senderId: 0
    property string content: ""
    property alias imageId: messageMedia.imageId

    property string imageHash: ""
    property string imageType: ""
    property int imageWidth: 0
    property int imageHeight: 0

    property bool ownMessage: senderId == yourId
    property int messageWidth: messageMedia.width > textContent.contentWidth ? messageMedia.width + 20 : (messageTime.contentWidth > textContent.contentWidth ? messageTime.contentWidth + 20 : textContent.contentWidth + 20)

    //Sizes
    property int messageSize: 15
    property int timeSize: messageSize - 5
    property int dMActionsSize: 15

    BackEnd {
        id: chatMessageBackend
    }

    Rectangle {
        id: chatMessageBody
        width: messageWidth
        height: childrenRect.height + 20
        x: ownMessage ? window.width - width - 15 : 5
        radius: 10
        color: ownMessage ? yourColor : targetColor

        ComboBox {
            id: chatMessageActions
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.topMargin: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            implicitWidth: comboBoxIcon.contentWidth
            currentIndex: -1

            background: Rectangle {
                id: comboBoxBackground
                color: "transparent"
                radius: height
            }

            textRole: "text"

            model: ListModel {
                id: comboBoxItems
                //ListElement { text: "Debug action" }
            }

            contentItem: Text {
                id: comboBoxIcon
                text: ic_arrow_down
                font.family: "FandidIcons"
                color: whiteTextColor
                font.pointSize: dMActionsSize
            }

            indicator: Canvas {} //To hide the default arrow icons

            popup: Popup {
                y: chatMessageActions.height - 1
                width: chatMessageActions.width
                implicitHeight: contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: chatMessageActions.popup.visible ? chatMessageActions.delegateModel : null
                    currentIndex: chatMessageActions.highlightedIndex
                }

                Behavior on implicitHeight {

                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            onPressedChanged: implicitWidth = 120

            onCurrentIndexChanged:
            {
                if (currentIndex == -1)
                    return

                //implicitWidth = comboBoxIcon.contentWidth

                switch(comboBoxItems.get(currentIndex).text)
                {
                    case "Debug action":
                    console.debug(content)
                    break

                    case "Report":
                        globalBackend.makeNotification("Error", "Reporting is not implemented")
                        break

                    case "Copy":
                        chatMessageBackend.copyTextToClipboard(chatMessage.content)
                        break

                    case "Save image":
                        chatMessageBackend.saveImage(chatMessage.id + "." + imageType)
                        break
                }

                currentIndex = -1
            }

            Component.onCompleted:
            {
                if (chatMessage.content.length > 0)
                    comboBoxItems.append({"text": "Copy"})

                //Add options dynamically depending on power level and ownership
                if (messageMedia.source != "")
                    comboBoxItems.append({"text": "Save image"})

                if (!ownMessage)
                    comboBoxItems.append({"text": "Report"})
            }
        }

        TextEdit {
            id: textContent
            readOnly: true
            selectByMouse: true
            anchors.left: parent.left
            anchors.top: chatMessageActions.visible ? chatMessageActions.bottom : parent.top
            anchors.leftMargin: 10
            anchors.topMargin: chatMessageActions.visible ? 5 : 10
            width: window.width - 40
            color: whiteTextColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: content
            font.pointSize: messageSize
            renderType: Text.NativeRendering
            textFormat: TextEdit.RichText
            Keys.onEscapePressed: focusWindow.focus = true
            onLinkActivated:
            {
                var properLink = link.replace("&amp;", "&")

                if (link.search("^https://") !== 0)
                    Qt.openUrlExternally("https://" + properLink)
                else
                    Qt.openUrlExternally(properLink)
            }

            MouseArea {
                enabled: platformIsMobile
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressAndHold:
                {
                    enabled = false
                    globalBackend.makeNotification("Select", "You can select text now")
                }
            }
        }

        Label {
            id: messageTime
            text: qsTr("10s")
            color: whiteTextColor
            font.pointSize: timeSize
            anchors.left: parent.left
            anchors.top: textContent.bottom
            anchors.leftMargin: 10
        }

        AnimatedImage {
            id: messageMedia

            property int scaleHeight: imageHeight === 0 ? sourceSize.height : imageHeight
            property int scaleWidth: imageWidth === 0 ? sourceSize.width : imageWidth

            width: visible ? (desktopIsFullscreen ? window.width * (1/4) : window.width * (3/4)) : 0
            height: scaleHeight * messageMedia.width / scaleWidth
            visible: source == "" ? false : true
            anchors.top: messageTime.bottom
            anchors.left: parent.left
            horizontalAlignment: Image.AlignLeft
            anchors.leftMargin: visible ? 10 : 0
            anchors.topMargin: visible ? 10 : 0

            //fillMode: Image.PreserveAspectFit

            //The endpoint for direct message images responds to the ID of the message itself and not the ID of the image

            property string imageId: ""
            source: imageId === "" ? "" : "Assets/Images/fandid_loading.gif"

            SequentialAnimation {
                running: false
                id: imageSwapAnimation

                PropertyAnimation {
                    target: messageMedia
                    property: "opacity"
                    to: 0
                    duration: 250
                    easing.type: Easing.Linear
                }

                ScriptAction {
                    script:
                    {
                        messageMedia.source = Qt.resolvedUrl("file:/" + cacheDir + chatMessage.id + "." + imageType)
                        messageMedia.playing = true
                    }
                }

                PropertyAnimation {
                    target: messageMedia
                    property: "opacity"
                    to: 1
                    duration: 250
                    easing.type: Easing.Linear
                }
            }

            Component.onCompleted: messageMedia.source != "" ? chatMessageBackend.loadImage(imageHash, imageType, chatMessage.id, userToken, false, true) : undefined

            MouseArea {
                anchors.fill: parent
                onClicked: chatMessageBackend.openImageExternally(cacheDir + chatMessage.id + "." + imageType)
            }
        }

        Connections {
            target: chatMessageBackend
            function onBlurhashReady()
            {
                messageMedia.source = Qt.resolvedUrl("file:/" + cacheDir + chatMessage.id + ".blurhash")
            }

            function onImageReady(cached)
            {
                if (cached)
                    messageMedia.source = Qt.resolvedUrl("file:/" + cacheDir + chatMessage.id + "." + imageType)
                else
                    imageSwapAnimation.running = true
            }
        }
    }
}
