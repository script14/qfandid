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
import RequestType 1.0

Item {

    Rectangle {
        id: chatPageTitleTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: chatPageTitle.contentHeight + 20
        color: globalBackgroundDarker
        z: 1

        Label {
            id: chatPageTitle
            width: window.width - 10
            text: qsTr("Your conversations")
            color: globalTextColor
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 18
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.NativeRendering
        }
    }

    function movePostFeedToBeginning()
        {
            chatPageMultiFeed.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
        }

    MultiFeed {
        id: chatPageMultiFeed
        type: RequestType.ROOMLIST
        anchors.top: chatPageTitleTopBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 10
    }
}
