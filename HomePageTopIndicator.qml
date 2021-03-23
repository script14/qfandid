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
    id: pageIndicator
    height: rectangle.height

    //Variables
    property int buttonSize: 20
    property int buttonImplicitWidth: rectangle.width / 3
    property int buttonImplicitHeight: rectangle.height
    property int buttonPadding: platformIsMobile ? 5 : 0
    property color selected: fandidYellowDarker
    property color deselected: topBarIndicatorDeselectedColor

    function colorButton(index)
    {
        switch(index)
        {
        case 0:
            newButtonContentItem.color = selected
            hotButtonContentItem.color = deselected
            searchButtonContentItem.color = deselected
            break
        case 1:
            newButtonContentItem.color = deselected
            hotButtonContentItem.color = selected
            searchButtonContentItem.color = deselected
            break
        case 2:
            hotButtonContentItem.color = deselected
            newButtonContentItem.color = deselected
            searchButtonContentItem.color = selected
        }
    }

    Rectangle {
        id: rectangle
        height: newButtonContentItem.contentHeight * (platformIsMobile ? 1.2 : 1.1)
        color: globalBackgroundDarker
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        RowLayout {
            id: homePageTopBar
            anchors.fill: parent
            spacing: 0

            Button {
                id: newButton
                text: qsTr("New")
                flat: true
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextOnly
                implicitWidth: buttonImplicitWidth
                implicitHeight: buttonImplicitHeight
                background.anchors.fill: this
                padding: buttonPadding

                contentItem: Text {
                    id: newButtonContentItem
                    text: parent.text
                    font: parent.font
                    color: selected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: homePageSwipeView.setCurrentIndex(0)
            }

            Button {
                id: hotButton
                text: qsTr("Hot")
                flat: true
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                display: AbstractButton.TextOnly
                implicitWidth: buttonImplicitWidth
                implicitHeight: buttonImplicitHeight
                background.anchors.fill: this
                padding: buttonPadding

                contentItem: Text {
                    id: hotButtonContentItem
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: homePageSwipeView.setCurrentIndex(1)
            }

            Button {
                id: searchButton
                text: qsTr("Search")
                flat: true
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                display: AbstractButton.TextOnly
                implicitWidth: buttonImplicitWidth
                implicitHeight: buttonImplicitHeight
                background.anchors.fill: this
                padding: buttonPadding

                contentItem: Text {
                    id: searchButtonContentItem
                    text: parent.text
                    font: parent.font
                    color: deselected
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: homePageSwipeView.setCurrentIndex(2)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.25;height:480;width:640}
}
##^##*/

