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

Item {

    Text {
        id: groupName
        width: window.width / 2
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.topMargin: 15
        color: postBody.color
        text: qsTr("Fandid")
        font.pointSize: nameSize
        renderType: Text.NativeRendering
        horizontalAlignment: Text.AlignRight
        font.weight: Font.Bold
        font.capitalization: Font.MixedCase
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        maximumLineCount: 1
        elide: Text.ElideRight

        Rectangle {
            id: groupBackground
            width: groupName.contentWidth + 10
            height: groupName.contentHeight + 5
            color: globalTextColor
            radius: 20
            anchors.verticalCenter: parent.verticalCenter
            z: -1

            MouseArea {
                id: groupMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: type !== RequestType.GROUPPOSTS
                onClicked: mainStackView.push("GroupView.qml", {"groupId": postGroupId, "groupName": groupName.text})
            }
        }
    }

}
