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
    //id: mePageTopIndicator
    height: rectangle.height

    property alias mePageTopIndicatorHeight: rectangle.height

    //Variables
    property int buttonSize: 13
    property int buttonImplicitHeight: rectangle.height

    property color selected: fandidYellowDarker
    property color deselected: globalTextColorDarker

    function colorButton(index)
    {
        switch(index)
        {
        case 0:
            notificationsButtonContentItem.color = selected
            yourPostsButtonContentItem.color = deselected
            followedPostsButtonContentItem.color = deselected
            joinedGroupsButtonContentItem.color = deselected
            break
        case 1:
            notificationsButtonContentItem.color = deselected
            yourPostsButtonContentItem.color = selected
            followedPostsButtonContentItem.color = deselected
            joinedGroupsButtonContentItem.color = deselected
            break
        case 2:
            notificationsButtonContentItem.color = deselected
            yourPostsButtonContentItem.color = deselected
            followedPostsButtonContentItem.color = selected
            joinedGroupsButtonContentItem.color = deselected
            break
        case 3:
            notificationsButtonContentItem.color = deselected
            yourPostsButtonContentItem.color = deselected
            followedPostsButtonContentItem.color = deselected
            joinedGroupsButtonContentItem.color = selected
            break
        }
    }

    Rectangle {
        id: rectangle
        height: notificationsButtonContentItem.contentHeight * 1.5
        color: globalBackgroundDarker
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        RowLayout {
            id: mePageTopIndicatorBar
            anchors.fill: parent
            spacing: 0

            Button {
                id: notificationsButton
                text: qsTr("Notifications")
                flat: true
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextOnly
                Layout.fillWidth: true
                implicitHeight: buttonImplicitHeight
                background.anchors.fill: this
                padding: 0

                contentItem: Text {
                    id: notificationsButtonContentItem
                    text: parent.text
                    font: parent.font
                    color: selected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: swipeViewMePage.setCurrentIndex(0)
            }

            Button {
                id: yourPostsButton
                text: qsTr("Your posts")
                flat: true
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                Layout.fillWidth: true
                display: AbstractButton.TextOnly
                implicitHeight: buttonImplicitHeight
                background.anchors.fill: this
                padding: 0

                contentItem: Text {
                    id: yourPostsButtonContentItem
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: swipeViewMePage.setCurrentIndex(1)
            }

            Button {
                id: followedPostsButton
                text: qsTr("Followed posts")
                flat: true
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextOnly
                Layout.fillWidth: true
                implicitHeight: buttonImplicitHeight
                background.anchors.fill: this
                padding: 0

                contentItem: Text {
                    id: followedPostsButtonContentItem
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: swipeViewMePage.setCurrentIndex(2)
            }

            Button {
                id: joinedGroupsButton
                text: qsTr("Groups")
                flat: true
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                Layout.fillWidth: true
                display: AbstractButton.TextOnly
                implicitHeight: buttonImplicitHeight
                background.anchors.fill: this
                padding: 0

                contentItem: Text {
                    id: joinedGroupsButtonContentItem
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: swipeViewMePage.setCurrentIndex(3)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.25;height:480;width:640}
}
##^##*/

