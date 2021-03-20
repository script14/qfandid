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
    id: postToGroupEntry
    width: rectangle.width
    height: rectangle.height

    //API response
    property int groupId: 0
    property int postCount: 0
    property int memberCount: 0
    property int riskLevel: 0
    property string groupName: "Fandid"
    property string groupDescription: "Fandid description"
    property bool own: false
    property bool joined: false

    Rectangle {
        id: rectangle
        width: window.width / 2
        anchors.left: parent.left
        anchors.right: parent.right
        height: button.height + border.width// * 2.5
        color: "transparent"
        border.color: "#414141"
        border.width: 6

        Button {
            id: button
            height: implicitContentHeight * 1.5
            width: postToGroupEntry.width - rectangle.border.width
            text: groupName
            anchors.leftMargin: rectangle.border.width / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            font.pointSize: 15
            font.capitalization: Font.MixedCase
            Material.background: globalBackgroundDarker
            background.anchors.fill: this
            leftPadding: 5

//            background: Rectangle {
//                id: buttonBackground
//                implicitWidth: postToGroupEntry.width - rectangle.border.width
//                implicitHeight: postButtonText.contentHeight
//                color: globalBackgroundDarker
//            }

            contentItem: Text {
                id: postButtonText
                text: parent.text
                font: parent.font
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
            }

            onClicked:
            {
                //This is to check whether this component is used when selecting groups from the search page or post creator
                if (typeof(searchPage) !== "undefined")
                    console.debug("I am unfinished")
                else if (typeof(postCreator) !== "undefined")
                {
                    postCreatorPreloader.onPreloadPostCreator(groupId, groupName, "", riskLevel > 0)
                    nsfwSwitch.checked = riskLevel
                }
            }
        }
    }
}
