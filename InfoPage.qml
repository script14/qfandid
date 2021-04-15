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
import QtQuick.Layouts 1.3

Item {

    property string imageSource: ""
    property string title: ""
    property int textSize: 15
    property string textContent: ""

    Component.onCompleted: focusWindow.focus = true
    Component.onDestruction: focusWindow.focus = true

    Rectangle {
        id: settingsPageTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: infoTitle.contentHeight + 20
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
            id: infoTitle
            width: window.width / 3
            text: title
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

    Flickable {
        anchors.top: settingsPageTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        contentHeight: image.paintedHeight + info.contentHeight + 100
        ScrollBar.vertical: MyScrollBar{}

        Image {
            id: image
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 5
            source: imageSource
            fillMode: Image.PreserveAspectFit
            Component.onCompleted:
            {
                if (imageSource.search(".svg") > 0)
                    sourceSize.height = sourceSize.width = platformIsMobile ? 100 : 200
                else
                    height = window.height / 5
            }
        }

        Text {
            id: info
            width: window.width - 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: image.bottom
            anchors.topMargin: 5
            leftPadding: 10
            rightPadding: 10
            font.pointSize: textSize
            color: globalTextColor
            textFormat: Text.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: textContent
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
