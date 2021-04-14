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
import QtQuick.Dialogs 1.3

Item {
    id: comment
    width: commentBody.width
    height: commentBody.height

    //API response
    property int pid: 0
    property int commentId: 0
    property int postId: 0
    property int parentId: 0

    property int riskLevel: 0

    property alias time: commentTime.text

    property alias loveCount: loveCount.text
    property alias hateCount: hateCount.text
    property int vote: 0

    property alias op: opIndicator.visible
    property alias own: youIndicator.visible

    property alias commentAvatar: commentAvatar.text
    property alias name: commentName.text
    property string commentColor: "blue"

    property string content: "And then he turns himself into a pickle. Funniest shit I've ever seen"
    property alias media: commentMedia.imageId

    property string imageHash: ""
    property string imageType: ""
    property int imageWidth: 0
    property int imageHeight: 0

    //Variables
    property color loveColor: "#fe4543"
    property color hateColor: "#a343fe"
    property int iconSize: commentTextSize + 7 //20
    property int replySize: commentTextSize + 2 //15
    property int nameSize: commentTextSize + 1 //platformIsMobile ? 14 : 13
    property int avatarSize: commentTextSize + 12 //25
    property int commentTextSize: userSettings["commentFontSize"]
    property int indicatorTextSize: nameSize - 4
    property int timeSize: commentTextSize - 3 //10
    property int commentActionsSize: nameSize + 2

    function sendUpdatedState()
    {
        multiFeed.updatePostCommentState(index, loveCount.text, hateCount.text, vote)
    }

    function loveComment()
    {
        if (vote == 1)
        {
            loveIcon.color = commentIconColor
            loveCount.text = (parseInt(loveCount.text) - 1)
            vote = 0
        }
        else if (vote == 0)
        {
            loveIcon.color = loveColor
            loveCount.text = (parseInt(loveCount.text) + 1)
            vote = 1
        }
        else
        {
            hateIcon.color = commentIconColor
            loveIcon.color = loveColor
            hateCount.text = (parseInt(hateCount.text) - 1)
            loveCount.text = (parseInt(loveCount.text) + 1)
            vote = 1
        }

        commentBackend.vote("CMNT", commentId, vote, userToken)
        sendUpdatedState()
    }

    function hateComment()
    {
        if (vote == 1)
        {
            loveIcon.color = commentIconColor
            hateIcon.color = hateColor
            hateCount.text = (parseInt(hateCount.text) + 1)
            loveCount.text = (parseInt(loveCount.text) - 1)
            vote = -1
        }
        else if (vote == 0)
        {
            hateIcon.color = hateColor
            hateCount.text = (parseInt(hateCount.text) + 1)
            vote = -1
        }
        else
        {
            hateIcon.color = commentIconColor
            hateCount.text = (parseInt(hateCount.text) - 1)
            vote = 0
        }

        commentBackend.vote("CMNT", commentId, vote, userToken)
        sendUpdatedState()
    }

    BackEnd {
        id: commentBackend
    }

    Rectangle {
        id: commentBody
        width: desktopIsFullscreen ? window.width / 3 : window.width - 60
        height: childrenRect.height
        color: "transparent"
        x:
        {
            if (parentId === 0)
                if (desktopIsFullscreen)
                    return width
                else
                    return 0
            else
                if  (desktopIsFullscreen)
                    return width + commentAvatar.contentWidth + commentTopLayout.anchors.leftMargin - commenterRowLayout.spacing
                else
                    return commentAvatar.contentWidth + commentTopLayout.anchors.leftMargin - commenterRowLayout.spacing
        }

        Label {
            id: commentAvatar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: 1
            color: commentColor
            text: "\ue917"
            font.pointSize: avatarSize
            textFormat: Text.RichText
            font.family: "FandidIcons"

            Rectangle {
                radius: 100
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.contentWidth - 2
                height: parent.contentHeight - 2
                color: userSettings["lightMode"] && comment.name === "Mod" ? globalBackground : avatarBackgroundColor
                z: -1
            }
        }

        ColumnLayout {
            id: commentTopLayout
            anchors.left: commentAvatar.right
            anchors.leftMargin: 5
            spacing: 0

            RowLayout {
                id: commenterRowLayout

                Label {
                    id: commentName
                    color: commentColor
                    text: qsTr("ExuberantRaptor")
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    font.pointSize: nameSize
                    font.weight: Font.Bold
                    renderType: Text.NativeRendering
                    styleColor: "#000000"
                }

                Rectangle {
                    id: youIndicator
                    width: youIndicatorText.contentWidth + 10
                    height: youIndicatorText.contentHeight + 5
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    visible: true
                    color: commentIndicatorColor
                    radius: 20
                    Layout.topMargin: 2

                    Label {
                        id: youIndicatorText
                        color: commentColor
                        text: qsTr("YOU")
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: indicatorTextSize
                        font.weight: Font.Bold
                        renderType: Text.NativeRendering
                    }
                }

                Rectangle {
                    id: opIndicator
                    width: opIndicatorText.contentWidth + 10
                    height: opIndicatorText.contentHeight + 5
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    visible: true
                    color: commentIndicatorColor
                    radius: 20
                    Layout.topMargin: 2
                    Label {
                        id: opIndicatorText
                        color: commentColor
                        text: qsTr("OP")
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: indicatorTextSize
                        renderType: Text.NativeRendering
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    id: nsfwBackground
                    width: nsfwIndicator.contentWidth + 10
                    height: nsfwIndicator.contentHeight + 5
                    visible: riskLevel > 0 ? true : false
                    color: globalTextColor
                    radius: 20
                    Label {
                        id: nsfwIndicator
                        color: commentColor
                        text: qsTr("NSFW")
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: indicatorTextSize
                        renderType: Text.NativeRendering
                        font.weight: Font.Bold
                    }
                }

                ComboBox {
                    id: commentActions
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    implicitWidth: comboBoxIcon.contentWidth
                    currentIndex: -1

                    background: Rectangle {
                        id: comboBoxBackground
                        color: "transparent"
                        radius: height
                    }

                    textRole: "text"

                    model: ListModel {
                        id: comboBoxItems
                        ListElement { text: "Share" }
                    }

                    contentItem: Text {
                        id: comboBoxIcon
                        text: ic_arrow_down
                        font.family: "FandidIcons"
                        color: globalTextColor
                        font.pointSize: commentActionsSize
                    }

                    indicator: Canvas {} //To hide the default arrow icons

                    popup: Popup {
                        y: commentActions.height - 1
                        width: commentActions.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: commentActions.popup.visible ? commentActions.delegateModel : null
                            currentIndex: commentActions.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        Behavior on implicitHeight {

                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }

                    onPressedChanged: implicitWidth = 120

                    onCurrentIndexChanged:
                    {
                        if (currentIndex == -1)
                            return

                        //implicitWidth = comboBoxIcon.contentWidth

                        switch(comboBoxItems.get(currentIndex).text)
                        {
                            case "Debug action":
                                console.debug(imageType)
                                break

                            case "Share":
                                commentBackend.sharePostOrComment(name + " on Fandid" + (content.length == 0 ?  " uploaded an image" : " said:\n" + content) + "\nJoin Fandid at " + linkWebsite + "\n")
                                break

                            case "Copy":
                                commentBackend.copyTextToClipboard(comment.content)
                                break

                            case "Save image":
                                commentBackend.saveImage(commentMedia.imageId + "." + imageType)
                                break

                            case "Delete":
                            case "Hide":
                            case "Ban":
                                if (own)
                                    confirmDelete.visible = true
                                else
                                {
                                    modConfirmAction.action = comboBoxItems.get(currentIndex).text
                                    modConfirmAction.visible = true
                                }

                                break

                            case "Report":
                                globalBackend.makeNotification("Error", "Reporting is not implemented")
                                break
                        }

                        currentIndex = -1
                    }

                    Component.onCompleted:
                    {
                        if (comment.content.length > 0)
                            comboBoxItems.append({"text": "Copy"})

                        //Add options dynamically depending on power level and ownership
                        if (commentMedia.source != "")
                            comboBoxItems.append({"text": "Save image"})

                        if (own)
                            comboBoxItems.append({"text": "Delete"})
                        else if (!own && userInfo["power"] < 3) //and not mod powers
                            comboBoxItems.append({"text": "Report"})
                        else
                        {
                            comboBoxItems.append({"text": "Delete"})
                            comboBoxItems.append({"text": "Hide"})
                            comboBoxItems.append({"text": "Ban"})
                        }
                    }
                }
            }

            Label {
                id: commentTime
                color: globalTextColor
                text: qsTr("2 hours ago")
                Layout.leftMargin: 2
                font.pointSize: timeSize
                renderType: Text.NativeRendering
            }
        }

        TextEdit {
            id: commentText
            readOnly: true
            selectByMouse: true
            width: commentBody.width - anchors.leftMargin - 20
            color: globalTextColor
            text: content
            anchors.left: parent.left
            anchors.top: commentTopLayout.bottom
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.leftMargin: commentAvatar.contentWidth + commentTopLayout.anchors.leftMargin + commenterRowLayout.spacing
            anchors.topMargin: 10
            font.pointSize: commentTextSize
            renderType: Text.NativeRendering
            textFormat: TextEdit.RichText
            Keys.onEscapePressed: focusWindow.focus = true
            onLinkActivated:
            {
                var properLink = link.replace("&amp;", "&")

                if (link.search("^https://") !== 0)
                    Qt.openUrlExternally("https://" + properLink)
                else
                    Qt.openUrlExternally(properLink)
            }

            MouseArea {
                enabled: platformIsMobile
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressAndHold:
                {
                    enabled = false
                    globalBackend.makeNotification("Select", "You can select text now")
                }
            }
        }

        RowLayout {
            id: commentButtons
            anchors.left: parent.left
            anchors.top: commentMedia.visible ? commentMedia.bottom : commentText.bottom
            spacing: 20
            anchors.topMargin: 10
            anchors.leftMargin: commentText.anchors.leftMargin

            RowLayout {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Label {
                    id: loveIcon
                    color: vote == 1 ? loveColor : commentIconColor
                    text: ic_love
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: iconSize
                    font.family: "FandidIcons"

                    MouseArea {
                        id: loveIconMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: loveComment()
                    }
                }

                Label {
                    id: loveCount
                    color: commentIconColor
                    text: qsTr("0")
                    renderType: Text.NativeRendering
                    font.pointSize: iconSize / 2

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: loveComment()
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Label {
                    id: hateIcon
                    color: vote == -1 ? hateColor : commentIconColor
                    text: ic_hate
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: iconSize
                    font.family: "FandidIcons"

                    MouseArea {
                        id: hateIconMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: hateComment()
                    }
                }

                Label {
                    id: hateCount
                    color: commentIconColor
                    text: qsTr("0")
                    renderType: Text.NativeRendering
                    font.pointSize: iconSize / 2

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: hateComment()
                    }
                }
            }

            Label {
                id: dmIcon
                color: own ? Qt.darker(commentIconColor, 2) : commentIconColor
                text: ic_email
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: iconSize
                font.family: "FandidIcons"

                MouseArea {
                    id: dmIconMouseArea
                    anchors.fill: parent
                    cursorShape: own ? undefined : Qt.PointingHandCursor
                    onClicked:
                    {
                        if (!own)
                            mainStackView.push("RoomInside.qml", {"postId": postId, "commentId": commentId, "yourId": 1, "newRoom": true, "oneAvatar": comment.commentAvatar,
                                                                                  "twoAvatar": comment.commentAvatar, "oneVn": comment.name, "twoVn": comment.name, "oneColor": comment.commentColor, "twoColor": comment.commentColor})
                    }
                }
            }

            Label {
                id: replyText
                color: commentIconColor
                text: qsTr("Reply")
                font.pointSize: replySize

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        //When you click reply on a normal comment, the parent ID of the reply must be set to the current comment ID, because you are making a first reply
                        //but if replying to a reply, the parent ID must be set to the parent of the reply, so the comment is properly added to the correct comment chain
                        commentsPage.parentId = parentId == 0 ? commentId : parentId
                        commentTextArea.forceActiveFocus()
                        commentsPage.commentIndex = index
                        commentsPage.replyPrefix = parentId == 0 ? "" : "@" + name +  " "
                        replyTarget.text = "@" + name
                        replyingNotifier.visible = true
                    }
                }
            }
        }

        AnimatedImage {
            id: commentMedia

            property int scaleHeight: imageHeight === 0 ? sourceSize.height : imageHeight
            property int scaleWidth: imageWidth === 0 ? sourceSize.width : imageWidth

            width: commentBody.width
            height: scaleHeight * (commentBody.width - commentBody.x) / scaleWidth
            visible: source == "" ? false : true
            anchors.left: parent.left
            anchors.top: commentText.bottom
            horizontalAlignment: Image.AlignLeft
            anchors.leftMargin: 10
            anchors.topMargin: 10

            //fillMode: Image.PreserveAspectFit

            property string imageId: ""
            source: imageId === "" ? "" : "Assets/Images/fandid_loading.gif"

            SequentialAnimation {
                running: false
                id: imageSwapAnimation

                PropertyAnimation {
                    target: commentMedia
                    property: "opacity"
                    to: 0
                    duration: 250
                    easing.type: Easing.Linear
                }

                ScriptAction {
                    script:
                    {
                        commentMedia.source = Qt.resolvedUrl("file:/" + cacheDir + commentMedia.imageId + "." + imageType)
                        commentMedia.playing = true
                    }
                }

                PropertyAnimation {
                    target: commentMedia
                    property: "opacity"
                    to: 1
                    duration: 250
                    easing.type: Easing.Linear
                }
            }

            Component.onCompleted: commentMedia.source != "" ? commentBackend.loadImage(imageHash, imageType, commentMedia.imageId, userToken, false, false) : undefined

            MouseArea {
                anchors.fill: parent
                onClicked: commentBackend.openImageExternally(cacheDir + commentMedia.imageId + "." + imageType)
            }
        }
    }

    Connections {
        target: commentBackend
        function onBlurhashReady()
        {
            commentMedia.source = Qt.resolvedUrl("file:/" + cacheDir + commentMedia.imageId + ".blurhash")
        }

        function onImageReady(cached)
        {
            if (cached)
                commentMedia.source = Qt.resolvedUrl("file:/" + cacheDir + commentMedia.imageId + "." + imageType)
            else
                imageSwapAnimation.running = true
        }

        function onPostOrCommentRemoved()
        {
            multiFeed.removePostOrComment(index)
        }
    }

    MessageDialog {
        id: confirmDelete
        visible: false
        title: "Delete"
        icon: StandardIcon.Question
        text: "Are you sure you want to delete your comment?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: commentBackend.deletePostOrComment(1, postId, commentId, userToken)
        onNo: visible = false
    }

    MessageDialog {
        id: modConfirmAction

        property string action: ""

        visible: false
        title: action + " " + name
        icon: StandardIcon.Question
        text: "Are you sure you want to " + action.toLowerCase() + " this comment as a mod?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: commentBackend.modAction(action.toLowerCase(), 1, commentId, userToken)
        onNo: visible = false
    }
}
