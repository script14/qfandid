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

Item {
    id: multiFeed

    BackEnd {
        id: multiFeedBackend
    }

    //These are control variables used to help reuse this MultiFeed in several different places. Values are passed to them from their parent components
    property int type: RequestType.NEW
    property int postId: 0
    property int groupId: 0
    property string groupSearch: "Fandid"
    property int notificationId: 0

    property alias externMultiFeedListView: multiFeedListView
    property alias externMultiModel: multiModel
    property alias externMultiFeedBackend: multiFeedBackend
    property int preloadThreshold:
    {
        switch (type)
        {
            case RequestType.ROOMLIST:
                return 15
            case RequestType.HOT:
                return 20
            case RequestType.NOTIFICATIONS:
                return 28
            default:
                return 12
        }
    }

    function loadFeed()
    {
        if (multiFeedListView.unlocked)
        {
            //console.log("Loading " + type)
            multiFeedListView.unlocked = false
            multiFeedBackend.getFeed(type, postId, groupId, groupSearch, notificationId, userToken)
        }
    }

    function refreshFeed()
    {
        refreshAnimation.running = true
    }

    function updatePostCommentState(feedIndex, loveCount, hateCount, postVote)
    {
        multiModel.setProperty(feedIndex, "love", parseInt(loveCount))
        multiModel.setProperty(feedIndex, "hate", parseInt(hateCount))
        multiModel.setProperty(feedIndex, "vote", postVote)
    }

    function updateGroupInfoState(feedIndex, state)
    {
        multiModel.setProperty(feedIndex, "joined", state)
    }

    function updateRoomSeen(feedIndex)
    {
        multiModel.setProperty(feedIndex, "seen", true)
        multiFeedListView.contentItem.children[feedIndex].item.seen = true
    }

    function setNotificationSeen(feedIndex)
    {
        multiModel.setProperty(feedIndex, "seen", true)
        multiFeedListView.contentItem.children[feedIndex].item.seen = true
    }

    function removePostOrComment(removeIndex)
    {
        multiModel.remove(removeIndex)
        if (type == RequestType.COMMENTS)
        {
            var comments = parseInt(multiModel.get(0).comment - 1)
            multiModel.setProperty(0, "comment", comments)
            multiFeedListView.contentItem.children[0].item.commentCount = comments
        }
    }

    ListView {
        id: multiFeedListView
        anchors.fill: parent
        model: multiModel
        delegate: multiDelegate
        spacing: type == RequestType.POSTTOGROUPENTRY ? 0 : 10
        ScrollBar.vertical: MyScrollBar{}
        maximumFlickVelocity: platformIsMobile ? 6000 : 3000
        //flickDeceleration: platformIsMobile ? undefined : maximumFlickVelocity * 1.5

        property bool unlocked: true
        property bool reachedEnd: false

        Component.onCompleted: loadFeed()

        onContentYChanged:
        {
            if (type == RequestType.GROUPSEARCH)
                return
            else if ((count - preloadThreshold) > 0 && indexAt(contentX, contentY) > (count - preloadThreshold) && !multiFeedListView.reachedEnd)
                loadFeed()
        }

        onVerticalOvershootChanged:
        {
            if (verticalOvershoot <= -120 && multiFeedListView.unlocked && !dragging)
            {
                if (type === RequestType.CONTENTSEARCH && mainStackView.depth > 1)
                {
                    type = RequestType.GROUPPOSTS
                    groupSearch = ""
                }
                else
                    multiFeedBackend.resetSkipId()

                refreshFeed()
            }
        }

        SequentialAnimation {

            running: false
            id: refreshAnimation

            PropertyAnimation {
                target: multiFeedListView
                property: "opacity"
                to: 0
                duration: 100
                easing.type: Easing.Linear
            }

            ScriptAction {
                script:
                {
                    multiFeedListView.model = 0
                    multiModel.clear()
                    multiFeedListView.model = multiModel
                    multiFeedBackend.resetLastId()
                    multiFeedListView.reachedEnd = false
                    loadFeed()
                }
            }

            PropertyAnimation {
                target: multiFeedListView
                property: "opacity"
                to: 1
                duration: 100
                easing.type: Easing.Linear
            }
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "y"; duration: 300 }
                NumberAnimation { property: "opacity"; to: 0; duration: 100 }
            }
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 300 }
        }
    }

    Component {
        id: multiDelegate

        //The delegate is a loader so that I can dynamically change what is displayed in the list view depending on the "model" property
        Loader {
            Component.onCompleted:
            {
                switch(model)
                {
                case 0:
                    setSource("Post.qml",
                     {
                        "pid": pid,
                        "postId": id,
                        "postGroupId": groupId,
                        "ownPost": isOwnPost,
                        "clicked": isClicked,
                        "followed": isFollowed,
                        "postAvatar": avatar,
                        "postName": name,
                        "postTime": time,
                        "postRiskLevel": riskLevel,
                        "postColor": colorCode,
                        "groupName": group,
                        "postText": text,
                        "postMedia": media,
                        "imageHash": imageHash,
                        "imageType": imageType,
                        "imageWidth": imageWidth,
                        "imageHeight": imageHeight,
                        "loveCount": love,
                        "hateCount": hate,
                        "commentCount": comment,
                        "postVote": vote
                     })
                    break
                case 1:
                    setSource("Comment.qml",
                     {
                        "pid": pid,
                        "commentId": id,
                        "postId": postId,
                        "parentId": parentId,
                        "riskLevel": riskLevel,
                        "time": time,
                        "loveCount": love,
                        "hateCount": hate,
                        "vote": vote,
                        "op": op,
                        "own": own,
                        "commentAvatar": avatar,
                        "name": name,
                        "commentColor": colorCode,
                        "content": content,
                        "media": media,
                        "imageHash": imageHash,
                        "imageType": imageType,
                        "imageWidth": imageWidth,
                        "imageHeight": imageHeight
                     })
                    break
                case 3:
                    setSource("PostNotification.qml",
                    {
                        "id": id,
                        "postId": postId,
                        "commentId": commentId,
                        "count": count,
                        "model": model,
                        "postContent": postContent,
                        "commenterAvatar": commenterAvatar,
                        "commentVn": commentVn,
                        "own": own,
                        "seen": seen
                    })
                    break
                case 2:
                case 7:
                    setSource("GroupInfo.qml",
                    {
                        "groupId": groupId,
                        "postCount": postCount,
                        "memberCount": memberCount,
                        "riskLevel": riskLevel,
                        "groupName": groupName,
                        "groupDescription": groupDescription,
                        "own": own,
                        "joined": joined
                    })
                    break
                case 9:
                    setSource("PostToGroupEntry.qml",
                    {
                        "groupId": groupId,
                        "postCount": postCount,
                        "memberCount": memberCount,
                        "riskLevel": riskLevel,
                        "groupName": groupName,
                        "groupDescription": groupDescription,
                        "own": own,
                        "joined": joined
                    })
                    break
                case 5:
                    setSource("RoomOutside.qml",
                    {
                        "id": id,
                        "time": time,
                        "postId": postId,
                        "commentId": commentId,
                        "yourId": yourId,
                        "lastMessage": lastMsg,
                        "oneAvatar": oneAvatar,
                        "oneVn": oneVn,
                        "oneColor": oneColor,
                        "twoAvatar": twoAvatar,
                        "twoVn": twoVn,
                        "twoColor": twoColor,
                        "seen": seen,
                        "blocked": blocked,
                        "youBlocked": youBlocked
                    })
                    break
                }
            }
        }
    }

    //This is a Connections object that listens for the signal "doAddPost" that is emitted from the C++ multiFeedBackend. It automatically differentiates signal names when "on" is prepended to the name
    //When it receives this signal, it triggers the "onDoAddPost" function which executes the QML function "addPost" from "multiFeedListView" and gives it the values passed from the C++ multiFeedBackend
    Connections {
        target: multiFeedBackend

        //onDoAddPost: multiFeedListView.addPost(text) //DEPRECATED syntax

        function onAddPost(pid, id, model, groupId, isOwnPost, isClicked, isFollowed, avatar, name, time, riskLevel, colorCode, group, text, media, imageHash, imageType, imageWidth, imageHeight, love, hate, comment, vote)
        {
            multiModel.append(
                {
                    "pid": pid,
                    "id": id,
                    "model": model,
                    "groupId": groupId,
                    "isOwnPost": isOwnPost,
                    "isClicked": isClicked,
                    "isFollowed": isFollowed,
                    "avatar": avatar,
                    "name": name,
                    "time": time,
                    "riskLevel": riskLevel,
                    "colorCode": colorCode,
                    "group": group,
                    "text": text,
                    "media": media,
                    "imageHash": imageHash,
                    "imageType": imageType,
                    "imageWidth": imageWidth,
                    "imageHeight": imageHeight,
                    "love": love,
                    "hate": hate,
                    "comment": comment,
                    "vote": vote
                }
                        )
        }

        function onAddComment(pid, id, model, riskLevel, postId, parentId, time, love, hate, vote, op, own, avatar, name, colorCode, content, media, imageHash, imageType, imageWidth, imageHeight)
        {
            multiModel.append(
                {
                    "pid": pid,
                    "id": id,
                    "model": model,
                    "riskLevel": riskLevel,
                    "postId": postId,
                    "parentId": parentId,
                    "time": time,
                    "love": love,
                    "hate": hate,
                    "vote": vote,
                    "op": op,
                    "own": own,
                    "avatar": avatar,
                    "name": name,
                    "colorCode": colorCode,
                    "content": content,
                    "media": media,
                    "imageHash": imageHash,
                    "imageType": imageType,
                    "imageWidth": imageWidth,
                    "imageHeight": imageHeight
                }
                        )
        }

        function onAddGroupInfo(groupId, postCount, memberCount, model, riskLevel, groupName, description, own, joined)
        {
            multiModel.append(
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

        function onAddRoomList(id, time, postId, commentId, yourId, model, lastMsg, oneAvatar, twoAvatar, oneVn, oneColor, twoVn, twoColor, seen, blocked, youBlocked)
        {
            multiModel.append(
                    {
                        "id": id,
                        "time": time,
                        "postId": postId,
                        "commentId": commentId,
                        "yourId": yourId,
                        "model": model,
                        "lastMsg": lastMsg,
                        "oneAvatar": oneAvatar,
                        "twoAvatar": twoAvatar,
                        "oneVn": oneVn,
                        "oneColor": oneColor,
                        "twoVn": twoVn,
                        "twoColor": twoColor,
                        "seen": seen,
                        "blocked": blocked,
                        "youBlocked": youBlocked
                    }

                        )
        }

        function onAddNotification(id, postId, commentId, count, model, postContent, commenterAvatar, commentVn, own, seen)
        {
            multiModel.append(
                {
                    "id": id,
                    "postId": postId,
                    "commentId": commentId,
                    "count": count,
                    "model": model,
                    "postContent": postContent,
                    "commenterAvatar": commenterAvatar,
                    "commentVn": commentVn,
                    "own": own,
                    "seen": seen
                }
                    )
        }

        function onUnlockPostFeed()
        {
            multiFeedListView.unlocked = true
        }

        function onReachedFeedEnd()
        {
            multiFeedListView.reachedEnd = true
        }
    }

    Connections {
        target: typeof(commentsPageBackend) != "undefined" ? commentsPageBackend : focusWindow
        ignoreUnknownSignals: true
        function onAddComment(pid, id, model, riskLevel, postId, parentId, time, love, hate, vote, op, own, avatar, name, colorCode, content, media, imageHash, imageType, imageWidth, imageHeight)
        {
            //This is to handle the signal when creating a comment. It is the same signal as when comments are auto loaded into the feed, but they don't conflict because this one is emitted from a different backend instance

            commentTextArea.clear()
            followed = true
            commentTextArea.enabled = true
            removeImage()
            sendButton.enabled = true
            sendButton.text = "Send"
            //sendButton.color = globalTextColor
            //sendButtonBackground.color = fandidYellowDarker
            myBusyIndicator.visible = false

            var insertIndex = commentsPage.parentId == 0 ? multiModel.count : commentIndex + 1
            commentIndex = commentsPage.parentId = 0
            replyPrefix = ""
            replyingNotifier.visible = false

            if (multiFeedListView.count == 1)
            {
                //This is because for some reason if there is only type of component loaded in the feed, when a new one is added dynamically later it sometimes does not accept the necessary values given to it and throws reference errors
                refreshFeed()
                return
            }

            //update insertIndex if the next comment already has replies, otherwise the comment visually won't be inserted at the end of the comment chain
            if (insertIndex != multiModel.count)
            {
                //Start from 1 because 0 is the post
                for (var i = insertIndex; i < multiModel.count; i++)
                {
                    if (multiModel.get(i).parentId != 0)
                        insertIndex++
                    else
                        break
                }
            }

            multiModel.insert(insertIndex, {"pid": pid, "id": id, "model": model, "riskLevel": riskLevel, "postId": postId, "parentId": parentId, "time": time, "love": love, "hate": hate, "vote": vote, "op": op, "own": own, "avatar": avatar,
                                  "name": name, "colorCode": colorCode, "content": content, "media": media, "imageHash": imageHash, "imageType": imageType, "imageWidth": imageWidth, "imageHeight": imageHeight})

            multiFeedListView.positionViewAtIndex(insertIndex, ListView.Center)

            var comments = parseInt(multiModel.get(0).comment + 1)
            multiModel.setProperty(0, "comment", comments)
            multiFeedListView.contentItem.children[0].item.commentCount = comments
        }
    }

    ListModel {
        id: multiModel

/*        ListElement {
            //id: "0"
            model: "0"
            groupId: "0"
            isOwnPost: false
            isClicked: false
            isFollowed: false

            avatar: "\ue917"
            name: "ExuberantRaptor"
            time: "1 hour ago"
            riskLevel: 0

            colorCode: "#1cacf5"
            group: "test"

            text: "Image"
            media: ""

            love: 0
            hate: 0
            comment: 0
            vote: 0
        }
*/
    }
}
