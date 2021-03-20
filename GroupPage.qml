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
    id: groupPage

    RowLayout {
        id: groupPageTopLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.topMargin: 10
        z: 1

        TextField {
            id: textField
            Layout.fillWidth: true
            renderType: Text.NativeRendering
            selectByMouse: platformIsMobile ? false : true
            placeholderText: qsTr("Type 3 characters")
            font.pointSize: 15
            Material.accent: fandidYellowDarker
            //leftPadding: textFieldImage.width + 30

            onAccepted:
            {
                if (textField.text.length >= 3)
                {
                    textField.focus = false
                    focusWindow.focus = true
                    multiFeedGroupPageLoader.active = false
                    suggestedGroupsLoader.active = false
                    multiFeedGroupPageLoader.active = true
                }
                else
                {
                    multiFeedGroupPageLoader.active = false
                    suggestedGroupsLoader.active = true
                }
            }

            Keys.onEscapePressed:
            {
                textField.focus = false
                focusWindow.focus = true
            }

//            background: Rectangle {
//                id: textFieldBackground
//                implicitWidth: 200
//                implicitHeight: platformIsMobile ? 20 : 40
//                color: globalBackgroundDarker
//                radius: 20
//            }

//            Image {
//                id: textFieldImage
//                source: "Assets/Vectors/ic_magnifying_glass.svg"
//                anchors.left: parent.left
//                anchors.leftMargin: 10
//                anchors.verticalCenter: parent.verticalCenter
//                sourceSize.height: textFieldBackground.implicitHeight / 1.1
//                sourceSize.width: height
//                height: sourceSize.height
//                width: sourceSize.width

//                MouseArea {
//                    anchors.fill: parent
//                    cursorShape: Qt.PointingHandCursor
//                    onClicked: textField.accepted()
//                }
//            }
        }

        RoundButton {
            id: button
            width: implicitContentWidth + 50
            height: implicitContentHeight + 20
            text: qsTr("Create")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            font.pointSize: 15
            font.capitalization: Font.MixedCase
            font.bold: true
            Material.background: fandidYellowDarker
            onClicked: mainStackView.push("GroupCreator.qml")

//            background: Rectangle {
//                implicitWidth: buttonText.contentWidth + 50
//                implicitHeight: buttonText.contentHeight
//                color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
//                radius: 20
//            }

//            contentItem: Text {
//                id: buttonText
//                text: parent.text
//                font: parent.font
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                color: parent.down ? Qt.darker(globalTextColor, 1.2) : globalTextColor
//            }
        }
    }

    Loader {
        id: suggestedGroupsLoader
        active: false
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: groupPageTopLayout.bottom
        anchors.leftMargin: 5
        anchors.topMargin: 10

        sourceComponent: SuggestedGroupsFeed {}
    }

    Loader {
        id: multiFeedGroupPageLoader
        active: false
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: groupPageTopLayout.bottom
        anchors.leftMargin: 5
        anchors.topMargin: 10

        sourceComponent: MultiFeed {
            type: RequestType.GROUPSEARCH
            groupSearch: textField.text
            clip: true
        }
    }

    Component.onCompleted: suggestedGroupsLoader.active = true
}
