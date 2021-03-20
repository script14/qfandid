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
import QtQuick.Layouts 1.0
import RequestType 1.0
import QtQuick.Controls.Material 2.12

Item {
    id: groupViewItem

    property int groupId: 0
    property alias groupName: groupNameText.text

    //Variables
    property int buttonSize: platformIsMobile ? 13 : 15

    Rectangle {
        id: groupViewTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: groupNameText.contentHeight + 20
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
                id: groupViewMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mainStackView.pop()
            }
        }

        Text {
            id: groupNameText
            width: groupViewTopBar.width - backButton.anchors.leftMargin - backButton.contentWidth - postButton.width - postButton.width
            text: "Fandid"
            color: globalTextColor
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.NativeRendering
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        RoundButton {
            id: postButton
            width: implicitContentWidth + 50
            height: implicitContentHeight + 20
            text: qsTr("Post")
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            font.pointSize: 15
            font.capitalization: Font.MixedCase
            Material.background: fandidYellowDarker
            radius: 20

//            background: Rectangle {
//                id: postButtonBackground
//                implicitWidth: postButtonText.contentWidth + 50
//                implicitHeight: postButtonText.contentHeight
//                color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
//                radius: 20
//            }

//            contentItem: Text {
//                id: postButtonText
//                text: parent.text
//                font: parent.font
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                color: parent.down ? globalTextColorDarker : globalTextColor
//            }

            onClicked:
            {
                mainStackView.push("PostCreator.qml")
                focusWindow.preloadPostCreator(groupId, groupName, "", (groupViewMultiFeed.externMultiModel.get(0).riskLevel > 0))
            }
        }
    }

    TextField {
        id: searchText
        anchors.top: groupViewTopBar.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        renderType: Text.NativeRendering
        placeholderText: qsTr("Search...")
        font.pointSize: 15
        Material.accent: fandidYellowDarker

//        background: Rectangle {
//            id: searchTextBackground
//            implicitWidth: window.width - 10
//            implicitHeight: platformIsMobile ? 10 : 20
//            color: globalBackgroundDarker
//            radius: 20
//        }

        onAccepted:
        {
            if (text.length >= 3)
                groupSearchContent()
            else
                globalBackend.makeNotification("Insufficient input", "Please write at least 3 characters")
        }
    }

    function groupSearchContent()
    {
        if (searchText.text.length !== 0)
        {
            groupViewMultiFeed.type = RequestType.CONTENTSEARCH
            groupViewMultiFeed.groupSearch = searchText.text
            groupViewMultiFeed.externMultiFeedBackend.resetSkipId()
            groupViewMultiFeed.externMultiFeedListView.unlocked = true
        }
        else
        {
            groupViewMultiFeed.type = RequestType.GROUPPOSTS
            groupViewMultiFeed.groupSearch = ""
        }

        groupViewMultiFeed.refreshFeed()
    }

    MultiFeed {
        id: groupViewMultiFeed
        type: RequestType.GROUPPOSTS
        groupId: groupViewItem.groupId
        externMultiFeedListView.clip: true
        anchors.top: searchText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 5
        anchors.topMargin: 10
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
