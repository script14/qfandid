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
            Material.foreground: buttonColor
            onClicked: mainStackView.push("GroupCreator.qml")
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
