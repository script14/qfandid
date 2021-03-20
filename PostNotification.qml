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

Item {
    id: postNotification
    width: rectangle.width
    height: rectangle.height

    //API response
    property int id: 0
    property int postId: 0
    property int commentId: 0
    property int count: 0
    property string postContent: "I'm Pickle Rick!!!"
    property string commenterAvatar: "Rick face"
    property string commentVn: "Rick S."
    property bool own: false
    property bool seen: false

    //Sizes
    property int avatarSize: platformIsMobile ? 17 : 20
    property int commentTextSize: platformIsMobile ? 12 : 14
    property int extraTextSize: platformIsMobile ? 12 : 14
    property int postTextSize: platformIsMobile ? 15 : 18

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
            spacing: platformIsMobile ? 5 : 0
            anchors.leftMargin: 10
            z: 1

            RowLayout {
                id: rowLayout
                spacing: 5

                Label {
                    id: commenterAvatar
                    text: postNotification.commenterAvatar
                    color: fandidYellow
                    font.family: "FandidIcons"
                    font.pointSize: avatarSize
                    renderType: Text.NativeRendering
                }

                Label {
                    id: commenterName
                    text: commentVn
                    color: fandidYellow
                    font.pointSize: commentTextSize
                    renderType: Text.NativeRendering
                }

                Label {
                    id: extraText
                    text: "has commented on " + (own ? "your " : "the ") + "post" + (count !== 0 ? " (+" + count + " more)" : "")
                    Layout.preferredWidth: window.width - columnLayout.anchors.leftMargin - rowLayout.spacing
                    font.pointSize: extraTextSize
                    color: fandidYellow
                    renderType: Text.NativeRendering
                    textFormat: Text.PlainText
                }
            }

            Text {
                id: postText
                text: postContent.length === 0 ? "<Picture>" : postContent
                elide: Text.ElideRight
                Layout.preferredWidth: window.width - columnLayout.anchors.leftMargin - rowLayout.spacing
                maximumLineCount: 1
                font.pointSize: postTextSize
                color: globalTextColor
                renderType: Text.NativeRendering
                textFormat: Text.PlainText
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
                mainStackView.push("CommentsPage.qml", {"postId": postId, "notificationId": id})
                multiFeed.setNotificationSeen(index)
            }
        }
    }
}
