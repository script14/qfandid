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
import RequestType 1.0
import QtQuick.Controls.Material 2.12

Item {
    id: groupInfo
    width: groupInfoBody.width
    height: groupInfoBody.height

    Component.onCompleted: focusWindow.enableGroupPostButton()

    BackEnd {
        id: groupInfoBackend
    }
    property bool horizontalInstance: false

    //API response
    property int groupId: 0
    property int postCount: 0
    property int memberCount: 0
    property int riskLevel: 0
    property string groupName: "Fandid"
    property string groupDescription: "Fandid description"
    property bool own: false
    property bool joined: false

    //Sizes
    property int indicatorTextSize: 10

    Rectangle {
        id: groupInfoBody
        width: desktopIsFullscreen ? window.width / 3 : window.width - 10
        height: horizontalInstance ? window.height - (horizontalInstance ? globalBottomBar.height + 80 : groupViewTopBar.height - 20) : childrenRect.height + groupNameLabel.anchors.topMargin
        x: desktopIsFullscreen && !horizontalInstance ? width : 0
        color: globalBackgroundDarker
        radius: 20

        Label {
            id: groupNameLabel
            width: horizontalInstance ? groupInfoBody.width - 10 : groupInfoBody.width / 2 - 30
            anchors.left: horizontalInstance ? undefined : parent.left
            anchors.top: parent.top
            anchors.leftMargin: horizontalInstance ? undefined : 20
            anchors.topMargin: horizontalInstance ? 50 : 20
            anchors.horizontalCenter: horizontalInstance ? parent.horizontalCenter : undefined
            color: globalTextColor
            text: groupName
            horizontalAlignment: horizontalInstance ? Text.AlignHCenter : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pointSize: horizontalInstance ? 20 : 15
            renderType: Text.NativeRendering
            font.bold: true
        }

        Rectangle {
            id: nsfwBackground
            anchors.left: horizontalInstance ? undefined : parent.left
            anchors.top: groupNameLabel.bottom
            anchors.leftMargin: horizontalInstance ? undefined : 20
            anchors.topMargin: 10
            anchors.horizontalCenter: horizontalInstance ? groupNameLabel.horizontalCenter : undefined
            width: nsfwIndicator.contentWidth + 10
            height: nsfwIndicator.contentHeight + 5
            visible: riskLevel > 0
            radius: 20

            Label {
                id: nsfwIndicator
                color: userSettings["lightMode"] ? globalTextColor : globalBackgroundDarker
                text: qsTr("NSFW")
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: indicatorTextSize
                renderType: Text.NativeRendering
                font.weight: Font.Bold
            }
        }

        Label {
            id: description
            color: globalTextColor
            text: groupDescription
            anchors.left: horizontalInstance ? undefined : parent.left
            anchors.top: horizontalInstance ? image.bottom : (nsfwBackground.visible ? nsfwBackground.bottom : groupNameLabel.bottom)
            width: horizontalInstance ? (groupInfoBody.width - anchors.leftMargin - anchors.rightMargin - 10) : (groupInfoBody.width - image.width - anchors.leftMargin - image.anchors.rightMargin - 50)
            maximumLineCount: horizontalInstance ? 5 : undefined
            elide: horizontalInstance ? Text.ElideRight : Text.ElideNone
            font.pointSize: horizontalInstance ? 16 : 13
            horizontalAlignment: horizontalInstance ? Text.AlignHCenter : Text.AlignJustify
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.leftMargin: horizontalInstance ? undefined : 20
            anchors.topMargin: 10
            renderType: Text.NativeRendering
            anchors.horizontalCenter: horizontalInstance ? parent.horizontalCenter : undefined
        }

        Label {
            id: groupOwnership
            visible: own ? true : false
            color: globalTextColor
            text: qsTr("You own this group")
            anchors.left: horizontalInstance ? undefined : parent.left
            anchors.top: description.bottom
            font.pointSize: description.font.pointSize + 2
            width: horizontalInstance ? groupInfoBody.width - 20 : groupInfoBody.width / 2
            horizontalAlignment: horizontalInstance ? Text.AlignHCenter : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAnywhere
            font.underline: true
            font.bold: true
            anchors.leftMargin: 20
            anchors.topMargin: 10
            Layout.fillWidth: true
            renderType: Text.NativeRendering
        }

        ColumnLayout {
            id: populationColumn
            anchors.left: horizontalInstance ? undefined : parent.left
            anchors.top: groupOwnership.visible ? groupOwnership.bottom : description.bottom
            anchors.topMargin: 10
            anchors.leftMargin: horizontalInstance ? undefined : 20
            Layout.alignment: Qt.AlignTop
            anchors.horizontalCenter: horizontalInstance ? parent.horizontalCenter : undefined

            Label {
                id: posts
                color: globalTextColor
                text: postCount + " Posts"
                font.pointSize: horizontalInstance ? 20 : 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.alignment: horizontalInstance ? Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignTop
                renderType: Text.NativeRendering
            }

            Label {
                id: members
                color: globalTextColor
                text: memberCount + " Members"
                font.pointSize: horizontalInstance ? 20 : 12
                horizontalAlignment: horizontalInstance ? Text.AlignVCenter : Text.AlignLeft
                verticalAlignment: horizontalInstance ? Text.AlignVCenter : Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.alignment: horizontalInstance ? Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignTop
                renderType: Text.NativeRendering
            }
        }

        Image {
            id: image
            source: "Assets/Images/logocolored.png"
            anchors.right: horizontalInstance ? undefined : parent.right
            anchors.top: horizontalInstance ? groupNameLabel.bottom : parent.top
            anchors.rightMargin: horizontalInstance ? undefined : 10
            anchors.topMargin: horizontalInstance ? 50 : 10
            anchors.horizontalCenter: horizontalInstance ? parent.horizontalCenter : undefined
            fillMode: Image.PreserveAspectFit
            width: platformIsMobile ? 100 : 200
            height: platformIsMobile ? 100 : 200
        }

        RoundButton {
            id: button
            width: implicitContentWidth + 50
            height: implicitContentHeight + 20
            text: joined ? "Leave" : "Join"
            font.bold: true
            font.capitalization: Font.MixedCase
            anchors.top: horizontalInstance ? undefined : image.bottom
            anchors.bottom: horizontalInstance ? parent.bottom : undefined
            anchors.right: horizontalInstance ? undefined : parent.right
            anchors.rightMargin: horizontalInstance ? undefined : image.width / 2 - width / 2 + image.anchors.rightMargin
            anchors.topMargin: horizontalInstance ? undefined : 5
            anchors.bottomMargin: horizontalInstance ? 50 : undefined
            font.pointSize: horizontalInstance ? 20 : 15
            anchors.horizontalCenter: horizontalInstance ? parent.horizontalCenter : undefined
            Material.background: joined ? Qt.lighter(globalBackground, 1.3) : fandidYellowDarker
            Material.foreground: joined ? globalTextColor : buttonColor
            radius: 20

            onClicked:
            {
                joined = !joined
                groupInfoBackend.joinGroup(joined, groupId, userToken)
                suggestedGroupsFeed.updateGroupInfoState(index, groupInfo.joined)
                multiFeed.updateGroupInfoState(index, groupInfo.joined)
            }
        }
    }

    MouseArea {
        anchors.fill: groupInfoBody
        z: -1
        onClicked:
        {
            if (type !== RequestType.GROUPPOSTS)
            {
                mainStackView.push("GroupView.qml", {"groupId": groupId, "groupName": groupName})
            }
        }
    }
}
