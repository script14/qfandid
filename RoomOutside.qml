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
import QtQuick.Layouts 1.0
import qFandid.Backend 1.0
import QtQuick.Dialogs 1.3

Item {
    id: roomOutside
    width: rectangle.width
    height: rectangle.height

    //API response
    property int id: 0
    property alias time: time.text
    property int postId: 0
    property int commentId: 0
    property int yourId: 0
    property string lastMessage: "Salutations"
    property string oneAvatar: ""
    property string oneVn: "ExuberantRaptor"
    property color oneColor: "blue"
    property string twoAvatar: ""
    property string twoVn: "TrickyPig"
    property color twoColor: "gray"
    property bool seen: false
    property bool blocked: false
    property bool youBlocked: false


    //Variables
    property int targetAvatarSize: 20//platformIsMobile ? 20 : 25
    property int targetSize: 15//platformIsMobile ? 15 : 18
    property int messageSize: 15//platformIsMobile ? 15 : 18
    property int timeSize: 10
    property int sourceButtonSize: 30
    property int dMActionsSize: targetSize + 2
    property string targetAvatar: yourId == 2 ? oneAvatar : twoAvatar
    property string targetColor: yourId == 2 ? oneColor : twoColor
    property string targetName: yourId == 2 ? oneVn : twoVn

    BackEnd {
        id: roomOutsideBackend
    }

    Rectangle {
        id: rectangle
        width: window.width - 10
        height: columnLayout.height + 10
        color: seen ? globalBackground : globalBackgroundDarker
        anchors.left: parent.left
        anchors.right: parent.right
        radius: 20

        ColumnLayout {
            id: columnLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: 0
            anchors.leftMargin: 10
            z: 1

            RowLayout {
                id: rowLayout
                spacing: 5

                Label {
                    id: targetAvatar
                    text: roomOutside.targetAvatar
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
                        color: userSettings["lightMode"] && roomOutside.targetName === "Mod" ? globalBackground : avatarBackgroundColor
                        z: -1
                    }
                }

                Label {
                    id: targetName
                    text: roomOutside.targetName
                    color: targetColor
                    font.pointSize: targetSize
                    renderType: Text.NativeRendering
                }

                ComboBox {
                    id: dMActions
                    Layout.alignment: Qt.AlignCenter
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
                        ListElement { text: "Block" }
                    }

                    contentItem: Text {
                        id: comboBoxIcon
                        text: ic_arrow_down
                        font.family: "FandidIcons"
                        color: globalTextColor
                        font.pointSize: dMActionsSize
                    }

                    indicator: Canvas {} //To hide the default arrow icons

                    popup: Popup {
                        y: dMActions.height - 1
                        width: dMActions.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: dMActions.popup.visible ? dMActions.delegateModel : null
                            currentIndex: dMActions.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
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
                            case "Block":
                                confirmBlock.visible = true
                                break
                            case "Ban":
                                console.debug("Banned")
                                break
                        }

                        currentIndex = -1
                    }

                    Component.onCompleted:
                    {
                        //If mod powers add ban option
                    }
                }
            }

            Text {
                id: message
                text: lastMessage.length == 0 ? "<Picture>" : lastMessage
                elide: Text.ElideRight
                Layout.preferredWidth: window.width - columnLayout.anchors.leftMargin - rowLayout.spacing - sourceButtonText.contentWidth * 1.5
                maximumLineCount: 1
                font.pointSize: messageSize
                color: globalTextColor
                renderType: Text.NativeRendering
                textFormat: Text.PlainText
            }

            Label {
                id: time
                text: qsTr("10s")
                font.pointSize: timeSize
                color: globalTextColor
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
                color: parent.down ? Qt.darker(targetName.color, 1.5) : targetName.color
            }

            onClicked:
            {
                mainStackView.push("CommentsPage.qml", {"postId": postId})
                focusWindow.focus = true
            }
        }

        Rectangle {
            width: rectangle.width
            height: 1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.bottom
            anchors.topMargin: 5
            color: globalTextColorDarker
        }

        MouseArea {
            anchors.fill: parent
            onClicked:
            {
                mainStackView.push("RoomInside.qml", {"roomId": id, "postId": postId, "yourId": yourId, "oneAvatar": oneAvatar, "oneVn": oneVn, "oneColor": oneColor, "twoAvatar": twoAvatar, "twoVn": twoVn, "twoColor": twoColor})
                multiFeed.updateRoomSeen(index)
            }
        }
    }

    MessageDialog {
        id: confirmBlock
        visible: false
        title: "Block"
        icon: StandardIcon.Question
        text: "Are you sure you want to block " + roomOutside.targetName + " ?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: roomOutsideBackend.blockDirectMessage(id, userToken)
        onNo: visible = false
    }

    Connections {
        target: roomOutsideBackend
        function onBlockedDirectMessage()
        {
            multiFeed.removePostOrComment(index)
            globalBackend.makeNotification("Blocked", "Blocked DM from " + roomOutside.targetName)
        }
    }
}
