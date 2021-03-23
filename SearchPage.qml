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
import QtQuick.Layouts 1.0
import RequestType 1.0
import QtQuick.Controls.Material 2.12

Item {
    id: searchPage

    property int buttonSize: platformIsMobile ? 13 : 15


    TextField {
        id: searchText
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        renderType: Text.NativeRendering
        placeholderText: qsTr("Search all groups...")
        Material.accent: fandidYellowDarker
        font.pointSize: 15

        onAccepted:
        {
            if (text.length >= 3)
                searchContent()
            else
                globalBackend.makeNotification("Insufficient input", "Please write at least 3 characters")
        }
    }

    function searchContent()
    {
        searchResultLoader.active = false
        searchResultLoader.active = true
    }

    function movePostFeedToBeginning()
    {
        searchResultLoader.item.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
    }

    Loader {
        id: searchResultLoader
        active: false
        anchors.top: searchText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 10
        sourceComponent: MultiFeed {
            type: RequestType.CONTENTSEARCH
            groupSearch: searchText.text
            groupId: 0
            externMultiFeedListView.clip: true
        }
    }
}
