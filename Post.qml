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
import RequestType 1.0

Item {
    id: post
    width: postBody.width
    height: postBody.height

    //Other

    //API response
    property int pid: 0
    property int postId: 0
    property int postGroupId: 0
    property bool ownPost: false
    property bool clicked: false
    property bool followed: false

    property alias postAvatar: postAvatar.text
    property alias postName: postName.text
    property alias postTime: postTime.text
    property int postRiskLevel: 0

    property alias postColor: postBody.color
    property alias groupName: groupName.text

    property string postText: "Kono Dio da!"
    property alias postMedia: postMedia.imageId

    property string imageHash: ""
    property string imageType: ""
    property int imageWidth: 0
    property int imageHeight: 0

    property alias loveCount: loveCount.text
    property alias hateCount: hateCount.text
    property alias commentCount: commentCount.text
    property int postVote: 0

    //Variables
    property color loveColor: "#fe4543"
    property color hateColor: "#a343fe"
    property int iconSize: postTextSize + 7 //25
    property int nameSize: postTextSize - 5 //platformIsMobile ? 14 : 13
    property int avatarSize: postTextSize + 12 //30
    property int postTextSize: userSettings["postFontSize"]
    property int indicatorTextSize: nameSize - 5
    property int timeSize: postTextSize - 8 //10
    property int postActionsSize: nameSize + 2
    property int outsideCharLimit: 500
    property int defaultHeight: 30 + posterLayout.height + postBottom.height + postText.contentHeight + postMedia.height
    property int postBodyHeight: postMedia.source == "" ? defaultHeight + (platformIsMobile ? 50 : 100) : defaultHeight

    //"index" is an internal property of the list view that is automatically managed and it is accessible here because each post instance is a child of the list view
    function sendUpdatedState()
    {
        multiFeed.updatePostCommentState(index, loveCount.text, hateCount.text, postVote)
    }

    function removePostFromFeed()
    {
        multiFeed.removePostOrComment(index)
    }

    function lovePost()
    {
        if (postVote == 1)
        {
            loveIcon.color = whiteTextColor
            loveCount.text = (parseInt(loveCount.text) - 1)
            postVote = 0
        }
        else if (postVote == 0)
        {
            loveIcon.color = loveColor
            loveCount.text = (parseInt(loveCount.text) + 1)
            postVote = 1
        }
        else
        {
            hateIcon.color = whiteTextColor
            loveIcon.color = loveColor
            hateCount.text = (parseInt(hateCount.text) - 1)
            loveCount.text = (parseInt(loveCount.text) + 1)
            postVote = 1
        }

        postBackend.vote("POST", postId, postVote, userToken)
        sendUpdatedState()
    }

    function hatePost()
    {
        if (postVote == 1)
        {
            loveIcon.color = whiteTextColor
            hateIcon.color = hateColor
            hateCount.text = (parseInt(hateCount.text) + 1)
            loveCount.text = (parseInt(loveCount.text) - 1)
            postVote = -1
        }
        else if (postVote == 0)
        {
            hateIcon.color = hateColor
            hateCount.text = (parseInt(hateCount.text) + 1)
            postVote = -1
        }
        else
        {
            hateIcon.color = whiteTextColor
            hateCount.text = (parseInt(hateCount.text) - 1)
            postVote = 0
        }

        postBackend.vote("POST", postId, postVote, userToken)
        sendUpdatedState()
    }

    //Since the follow bell is in another component, set its value properly only when this post is opened within the comments page
    Component.onCompleted: typeof(commentsPage) != "undefined" ? commentsPage.followed = followed : undefined

    BackEnd {
        id: postBackend
    }

    Rectangle {
        id: postBody
        width: desktopIsFullscreen ? window.width / 3 : window.width - 10
        height: postBodyHeight
        x: desktopIsFullscreen ? width : 0
        color: "#1d98ef"
        radius: 20

        Text {
            id: groupName
            width: postBody.width - postAvatar.anchors.leftMargin - postAvatar.contentWidth - posterLayout.anchors.leftMargin - posterLayout.childrenRect.width - comboBoxIcon.contentWidth
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 10
            anchors.topMargin: 15
            color: postBody.color
            text: qsTr("Fandid")
            font.pointSize: nameSize
            renderType: Text.NativeRendering
            horizontalAlignment: Text.AlignRight
            font.weight: Font.Bold
            font.capitalization: Font.MixedCase
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 1
            elide: Text.ElideRight

            Rectangle {
                id: groupBackground
                width: groupName.contentWidth + 10
                height: groupName.contentHeight + 5
                x: parent.width - parent.contentWidth - parent.anchors.rightMargin / 2
                anchors.verticalCenter: parent.verticalCenter
                color: whiteTextColor
                radius: 20
                z: -1

                MouseArea {
                    id: groupMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: type !== RequestType.GROUPPOSTS
                    onClicked: mainStackView.push("GroupView.qml", {"groupId": postGroupId, "groupName": groupName.text})
                }
            }
        }

        Rectangle {
            id: postBottom
            width: postBody.width
            height: loveIcon.contentHeight * 1.2
            color: Qt.darker(postBody.color, 1.7)
            radius: postBody.radius
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Rectangle {
                id: bottomTop
                width: postBottom.width
                height: postBottom.height / 2
                color: postBottom.color
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
            }

            RowLayout {
                id: postBottomRow
                visible: true
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                RowLayout {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Label {
                        id: loveIcon
                        color: postVote == 1 ? loveColor : whiteTextColor
                        text: ic_love
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: iconSize
                        font.family: "FandidIcons"

                        MouseArea {
                            id: loveIconMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: lovePost()
                        }
                    }

                    Label {
                        id: loveCount
                        color: whiteTextColor
                        text: qsTr("0")
                        renderType: Text.NativeRendering
                        font.pointSize: iconSize / 2

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: lovePost()
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Label {
                        id: hateIcon
                        color: postVote == -1 ? hateColor : whiteTextColor
                        text: ic_hate
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: iconSize
                        font.family: "FandidIcons"

                        MouseArea {
                            id: hateIconMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: hatePost()
                        }
                    }

                    Label {
                        id: hateCount
                        color: whiteTextColor
                        text: qsTr("0")
                        renderType: Text.NativeRendering
                        font.pointSize: iconSize / 2

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: hatePost()
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Label {
                        id: commentIcon
                        color: whiteTextColor
                        text: ic_comment
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: iconSize
                        font.family: "FandidIcons"

                        function openPost()
                        {
                            if (!post.clicked)
                                mainStackView.push("CommentsPage.qml", {"postId": postId, "shortcutToPost": post})
                        }

                        MouseArea {
                            id: commentIconMouseArea
                            anchors.fill: parent
                            cursorShape: !post.clicked ? Qt.PointingHandCursor : undefined
                            onClicked: commentIcon.openPost()
                        }
                    }

                    Label {
                        id: commentCount
                        color: whiteTextColor
                        text: qsTr("0")
                        renderType: Text.NativeRendering
                        font.pointSize: iconSize / 2

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: commentIcon.openPost()
                        }
                    }
                }
                Label {
                    id: dmIcon
                    color: ownPost ? globalTextColorDarker : whiteTextColor
                    text: ic_email
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: iconSize
                    font.family: "FandidIcons"

                    MouseArea {
                        id: dmIconMouseArea
                        anchors.fill: parent
                        cursorShape: ownPost ? undefined : Qt.PointingHandCursor
                        onClicked:
                        {
                            if (!ownPost)
                                mainStackView.push("RoomInside.qml", {"postId": postId, "commentId": 0, "yourId": 1, "newRoom": true, "oneAvatar": post.postAvatar,
                                                                                          "twoAvatar": post.postAvatar, "oneVn": post.postName, "twoVn": post.postName, "oneColor": post.postColor, "twoColor": post.postColor})
                        }
                    }
                }
            }
        }

        Label {
            id: postAvatar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.topMargin: 10
            color: Qt.lighter(postBody.color, 1.3)
            text: "\ue917"
            font.pointSize: avatarSize
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            textFormat: Text.RichText
            font.family: "FandidIcons"

            Rectangle {
                radius: 100
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.contentWidth - 2
                height: parent.contentHeight - 2
                color: userSettings["lightMode"] && post.postName === "Mod" ? globalBackground : avatarBackgroundColor
                z: -1
            }
        }

        RowLayout {
            id: posterLayout
            anchors.left: postAvatar.right
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: platformIsMobile ? 12 : 10

            ColumnLayout {

                spacing: 0

                RowLayout {

                    Label {
                        id: postName
                        color: whiteTextColor
                        text: qsTr("ExuberantRaptor")
                        renderType: Text.NativeRendering
                        font.weight: Font.Bold
                        styleColor: "#000000"
                        font.pointSize: nameSize
                    }

                    Rectangle {
                        id: nsfwBackground
                        width: nsfwIndicator.contentWidth + 10
                        height: nsfwIndicator.contentHeight + 5
                        visible: postRiskLevel > 0 ? true : false
                        color: whiteTextColor
                        radius: 20

                        Label {
                            id: nsfwIndicator
                            color: postBody.color
                            text: qsTr("NSFW")
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: indicatorTextSize
                            renderType: Text.NativeRendering
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        id: opBackground
                        width: opIndicator.contentWidth + 10
                        height: opIndicator.contentHeight + 5
                        visible: ownPost ? true : false
                        color: whiteTextColor
                        radius: 20

                        Label {
                            id: opIndicator
                            color: postBody.color
                            text: qsTr("YOU")
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: indicatorTextSize
                            renderType: Text.NativeRendering
                            font.weight: Font.Bold
                        }
                    }

                    ComboBox {
                        id: postActions
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
                            color: whiteTextColor
                            font.pointSize: postActionsSize
                        }

                        indicator: Canvas {} //To hide the default arrow icons

                        popup: Popup {
                            y: postActions.height - 1
                            width: postActions.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 1

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: postActions.popup.visible ? postActions.delegateModel : null
                                currentIndex: postActions.highlightedIndex
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
                                    console.debug(postId)
                                    break

                                case "Share":
                                    postBackend.sharePostOrComment(post.postName + " on Fandid" + (post.postText.length == 0 ?  " uploaded an image" : " said:\n" + post.postText) + "\nJoin Fandid at " + linkWebsite + "\n")
                                    break

                                case "Save image":
                                    postBackend.saveImage(postMedia.imageId + "." + imageType)
                                    break

                                case "Delete":
                                case "Hide":
                                case "Ban":
                                    if (ownPost)
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
                            //Add options dynamically depending on power level and ownership
                            if (postMedia.source != "")
                                comboBoxItems.append({"text": "Save image"})

                            if (ownPost)
                                comboBoxItems.append({"text": "Delete"})
                            else if (!ownPost && userInfo["power"] < 3) //and not mod powers
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
                    id: postTime
                    color: whiteTextColor
                    text: qsTr("2 hours ago")
                    font.pointSize: timeSize
                    renderType: Text.NativeRendering
                }
            }
        }

        TextEdit {
            id: postText
            readOnly: true
            selectByMouse: clicked
            width: postBody.width - 20
            color: whiteTextColor
            text: post.postText.length >= outsideCharLimit && !clicked ? post.postText + "..." : post.postText
            anchors.top: posterLayout.bottom
            anchors.bottom: postMedia.visible ? postMedia.top : postBottom.top
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pointSize: postTextSize
            renderType: Text.NativeRendering
            anchors.horizontalCenter: parent.horizontalCenter
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
                enabled: clicked && platformIsMobile
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressAndHold:
                {
                    enabled = false
                    globalBackend.makeNotification("Select", "You can select text now")
                }
            }
        }

        AnimatedImage {
            id: postMedia

            property bool noOutsideNsfw: post.postRiskLevel > 0 && !userSettings["doNotHideNsfw"] && !clicked && type !== RequestType.MODLOG && type !== RequestType.GROUPPOSTS

            //Images that have blurhash also provide their dimensions in advance so the height of the post can be set in advance
            //When the real image is loaded, ths post will not suddenly change its height from its previous state
            property int scaleHeight: imageHeight === 0 ? sourceSize.height : imageHeight
            property int scaleWidth: imageWidth === 0 ? sourceSize.width : imageWidth

            width: postBody.width
            height:
            {
                if (scaleHeight > 2160)
                    if (clicked)
                        return scaleHeight * postBody.width / scaleWidth
                    else
                        return scaleHeight
                else
                    return scaleHeight * postBody.width / scaleWidth
            }

            anchors.bottom: postBottom.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: source == "" ? false : true

            //fillMode: Image.PreserveAspectFit //A bit redundant because the ideal dimensions are already calculated

            property string imageId: ""
            source:
            {
                if (imageId === "")
                    return ""
                else if (noOutsideNsfw)
                    return "Assets/Images/contains_nsfw.png"
                else if (!noOutsideNsfw && userSettings["loadImagesOnlyInPostPage"])
                    return "Assets/Images/contains_image.png"
                else
                    return "Assets/Images/fandid_loading.gif"
            }

            //This is to create a minimal animation when switching from the placeholder image to the actual one for the first time. This is only activated if the image has not been cached in advance
            //First make the placeholder disappear with the opacity property in 200 milliseconds, then switch out the image, then set the opacity back to 1 over 200 milliseconds
            SequentialAnimation {
                running: false
                id: imageSwapAnimation

                PropertyAnimation {
                    target: postMedia
                    property: "opacity"
                    to: 0
                    duration: 250
                    easing.type: Easing.Linear
                }

                ScriptAction {
                    script:
                    {
                        postMedia.source = Qt.resolvedUrl("file:/" + cacheDir + postMedia.imageId + "." + imageType)
                        postMedia.playing = true
                    }
                }

                PropertyAnimation {
                    target: postMedia
                    property: "opacity"
                    to: 1
                    duration: 250
                    easing.type: Easing.Linear
                }
            }

            //Once an instance of a post has been created in the post feed list view, if it has an image, call the C++ function to load the image
            //Every post instance creates its own instance of the C++ backend, called postBackend
            //The loadImage function is called from a local instance of the backend so that the ImageReady signal is returned with the correct image ID
            //If this function was called from the globalBackend defined in main.qml,
            //EVERY post instance would pick up the signal and all of them would have the wrong image because they can't tell which signal is intended for which post
            //It doesn't look pretty when that happens
            Component.onCompleted:
            {
                if (postMedia.source != "")
                {
                    var doNotLoadOutside = (userSettings["loadImagesOnlyInPostPage"] && !clicked) || noOutsideNsfw

                    postBackend.loadImage(imageHash, imageType, postMedia.imageId, userToken, doNotLoadOutside, false)
                }
            }
        }

        MouseArea {
            id: postMouseArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: post.clicked ? postMedia.top : postText.top
            anchors.bottom: postBottom.top

            onClicked:
            {
                if (!post.clicked)
                    mainStackView.push("CommentsPage.qml", {"postId": postId, "shortcutToPost": post})
                else
                    postBackend.openImageExternally(cacheDir + postMedia.imageId + "." + imageType)
            }
        }
    }

    Connections {
        target: postBackend
        function onBlurhashReady()
        {
            postMedia.source = Qt.resolvedUrl("file:/" + cacheDir + postMedia.imageId + ".blurhash")
        }

        function onImageReady(cached)
        {
            if (cached)
                postMedia.source = Qt.resolvedUrl("file:/" + cacheDir + postMedia.imageId + "." + imageType)
            else
                imageSwapAnimation.running = true
        }

        function onPostOrCommentRemoved()
        {
            if (!clicked)
                removePostFromFeed()
            else
            {
                //If the post is deleted while you are inside of it,
                //go back to the previous page and remove the post from that previous MultiFeed
                commentsPage.shortcutToPost.removePostFromFeed()
                mainStackView.pop()
            }
        }
    }

    MessageDialog {
        id: confirmDelete
        visible: false
        title: "Delete"
        icon: StandardIcon.Question
        text: "Are you sure you want to delete your post?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: postBackend.deletePostOrComment(0, postId, 0, userToken)
        onNo: visible = false
    }

    MessageDialog {
        id: modConfirmAction

        property string action: ""

        visible: false
        title: action + " " + post.postName
        icon: StandardIcon.Question
        text: "Are you sure you want to " + action.toLowerCase() + " this post as a mod?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: postBackend.modAction(action.toLowerCase(), 0, postId, userToken)
        onNo: visible = false
    }
}
