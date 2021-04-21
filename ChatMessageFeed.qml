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

//This is essentially a stripped down version of the MultiFeed component because it was easier to make a modified copy than to further edit the original to handle the requirements of the chat message feed

Item {
    id: chatMessageFeed

    BackEnd {
        id: chatMessageBackend
    }

    property int roomId: 0
    property bool polling: false
    property bool newRoom: false

    function loadFeed()
    {
        if (chatMessageListView.unlocked)
        {
            chatMessageListView.unlocked = false
            chatMessageBackend.getFeed(RequestType.CHATMESSAGES, roomId, 0, "", 0, userToken)
        }
    }

    ListView {
        id: chatMessageListView
        anchors.fill: parent
        model: chatMessageModel
        delegate: chatMessageDelegate
        spacing: 10
        ScrollBar.vertical: MyScrollBar{height: platformIsMobile ? 20 : 15}
        maximumFlickVelocity: 5000
        verticalLayoutDirection: ListView.BottomToTop

        property bool unlocked: true

        Component.onCompleted: loadFeed()

        onContentYChanged:
        {
            var position = indexAt(contentX, contentY)
            if (position >= (count - 15))
                loadFeed()
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300 }
            NumberAnimation { property: "y"; duration: 300 }
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 300 }
        }
    }

    Component {
        id: chatMessageDelegate

        Loader {
            Component.onCompleted:
            {
                setSource("ChatMessage.qml",
                {
                    "id": id,
                    "time": time,
                    "senderId": senderId,
                    "originalText": originalText,
                    "content": content,
                    "imageId": media,
                    "imageHash": imageHash,
                    "imageType": imageType,
                    "imageWidth": imageWidth,
                    "imageHeight": imageHeight
                })
            }
        }
    }

    Connections {
        target: chatMessageBackend
        function onAddChatMessage(newMessage, id, time, senderId, model, originalText, content, media, imageHash, imageType, imageWidth, imageHeight)
        {
            chatMessageModel.insert(newMessage ? 0 : chatMessageListView.count,
                {
                    "id": id,
                    "time": time,
                    "senderId": senderId,
                    "model": model,
                    "originalText": originalText,
                    "content": content,
                    "media": media,
                    "imageHash": imageHash,
                    "imageType": imageType,
                    "imageWidth": imageWidth,
                    "imageHeight": imageHeight
                }
                    )
        }

        function onUnlockPostFeed()
        {
            chatMessageListView.unlocked = true

            if (!polling && !newRoom)
            {
                chatMessageBackend.startDirectMessageLongPolling(roomId, userToken)
                polling = true
            }
        }
    }

    ListModel {
        id: chatMessageModel
    }
}
