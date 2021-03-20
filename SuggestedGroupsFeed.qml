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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import qFandid.Backend 1.0
import RequestType 1.0

//This is essentially a stripped down version of the MultiFeed component because it was easier to make a modified copy than to further edit the original to handle the requirements of the suggested groups feed

Item {
    id: suggestedGroupsFeed

    property int type: RequestType.SUGGESTEDGROUPS

    BackEnd {
        id: suggestedGroupsBackend
    }

    function updateGroupInfoState(feedIndex, state)
    {
        suggestedGroupsModel.setProperty(feedIndex, "joined", state)
    }

    property int groupId: 0
    property string groupSearch: "Fandid"

    function loadFeed()
    {
        if (suggestedGroupsListView.unlocked)
        {
            suggestedGroupsListView.unlocked = false
            suggestedGroupsBackend.getFeed(type, 0, groupId, groupSearch, 0, userToken)
        }
    }

    ListView {
        id: suggestedGroupsListView
        anchors.fill: parent
        model: suggestedGroupsModel
        delegate: suggestedGroupsDelegate
        spacing: 10
        ScrollBar.horizontal: ScrollBar{height: platformIsMobile ? 10 : 15}
        maximumFlickVelocity: 5000
        orientation: ListView.Horizontal
        clip: true

        property bool unlocked: true

        Component.onCompleted: loadFeed()

        onContentXChanged:
        {
            var position = indexAt(contentX, contentY)
            if (position >= (count - 12))
                loadFeed()
        }

        add: Transition {

            NumberAnimation {
                property: "opacity"
                to: 1
                duration: 200
            }
         }

        remove: Transition {

            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 100
            }
         }
    }

    Component {
        id: suggestedGroupsDelegate

        Loader {
            Component.onCompleted:
            {
                setSource("GroupInfo.qml",
                {
                    "horizontalInstance": true,

                    "groupId": groupId,
                    "postCount": postCount,
                    "memberCount": memberCount,
                    "riskLevel": riskLevel,
                    "groupName": groupName,
                    "groupDescription": groupDescription,
                    "own": own,
                    "joined": joined
                })
            }
        }
    }

    Connections {
        target: suggestedGroupsBackend
        function onAddGroupInfo(groupId, postCount, memberCount, model, riskLevel, groupName, description, own, joined)
        {
            suggestedGroupsModel.append(
                {
                    "groupId": groupId,
                    "postCount": postCount,
                    "model": model,
                    "memberCount": memberCount,
                    "riskLevel": riskLevel,
                    "groupName": groupName,
                    "groupDescription": description,
                    "own": own,
                    "joined": joined
                }
                    )
        }

        function onUnlockPostFeed()
        {
            suggestedGroupsListView.unlocked = true
        }
    }

    ListModel {
        id: suggestedGroupsModel
    }
}
