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
import qFandid.Backend 1.0
import QtQuick.Layouts 1.0
import RequestType 1.0
import QtQuick.Controls.Material 2.12

Item {
    id: mePage

    //Sizes
    property int topIndicatorSize: 12
    property int bottomIndicatorSize: topIndicatorSize - 2
    property int settingsIconSize: 25
    property int indicatorWidth: mePageTopBar.width * (1/5)
    property int indicatorRadius: platformIsMobile ? 10 : 20

    Rectangle {
        id: mePageTopBar
        height: settingsButton.height + topRowLayout.anchors.topMargin + topRowLayout.anchors.bottomMargin
        width: window.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: globalBackgroundDarker
        z: 1

        RowLayout {
            id: topRowLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: platformIsMobile ? 0 : 10
            anchors.bottomMargin: platformIsMobile ? 0 : 10
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            spacing: platformIsMobile ? 5 : 10

            Rectangle {
                id: pointsIndicator
                width: indicatorWidth
                height: childrenRect.height + 10
                color: globalBackground
                radius: indicatorRadius
                Layout.fillWidth: true

                Label {
                    id: pointsCounter
                    text: userInfo["points"]
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    renderType: Text.NativeRendering
                    color: fandidYellowDarker
                    font.pointSize: topIndicatorSize
                }

                Label {
                    id: pointsLabel
                    text: "points"
                    anchors.top: pointsCounter.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    color: fandidYellow
                    font.pointSize: bottomIndicatorSize
                }
            }

            Rectangle {
                id: groupsIndicator
                width: indicatorWidth
                height: childrenRect.height + 10
                color: globalBackground
                radius: indicatorRadius
                Layout.fillWidth: true

                Label {
                    id: groupsCounter
                    text: userInfo["groups"]
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    renderType: Text.NativeRendering
                    color: fandidYellowDarker
                    font.pointSize: topIndicatorSize
                }

                Label {
                    id: groupsLabel
                    text: "groups"
                    anchors.top: groupsCounter.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    color: fandidYellow
                    font.pointSize: bottomIndicatorSize
                }
            }

            Rectangle {
                id: postsIndicator
                width: indicatorWidth
                height: childrenRect.height + 10
                color: globalBackground
                radius: indicatorRadius
                Layout.fillWidth: true

                Label {
                    id: postsCounter
                    text: userInfo["posts"]
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    renderType: Text.NativeRendering
                    color: fandidYellowDarker
                    font.pointSize: topIndicatorSize
                }

                Label {
                    id: postsLabel
                    text: "posts"
                    anchors.top: postsCounter.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    color: fandidYellow
                    font.pointSize: bottomIndicatorSize
                }
            }

            Rectangle {
                id: commentsIndicator
                width: indicatorWidth
                height: childrenRect.height + 10
                color: globalBackground
                radius: indicatorRadius
                Layout.fillWidth: true

                Label {
                    id: commentsCounter
                    text: userInfo["comments"]
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    renderType: Text.NativeRendering
                    color: fandidYellowDarker
                    font.pointSize: topIndicatorSize
                }

                Label {
                    id: commentsLabel
                    text: "comments"
                    anchors.top: commentsCounter.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    color: fandidYellow
                    font.pointSize: bottomIndicatorSize
                }
            }

            Button {
                id: settingsButton
                text: "<span style=font-size:" + settingsIconSize + "pt>" + ic_settings + "</span><br><span style=font-size:" + bottomIndicatorSize + "pt>Settings</span>"
                font.family: "FandidIcons"
                Layout.fillWidth: true
                font.capitalization: Font.MixedCase
                Material.background: globalBackgroundDarker
                Material.elevation: 0
                background.anchors.fill: this
                padding: 0

//                background: Rectangle {
//                    id: settingsButtonBackground
//                    implicitWidth: settingsButtonText.contentWidth
//                    implicitHeight: settingsButtonText.contentHeight
//                    color: "transparent"
//                }

                contentItem: Text {
                    id: settingsButtonText
                    text: parent.text
                    font: parent.font
                    textFormat: Text.RichText
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                }

                onClicked: mainStackView.push("SettingsPage.qml")
            }

//                Label {
//                    id: settingsLabel
//                    text: "Settings"
//                    anchors.top: settingsButton.bottom
//                    anchors.left: parent.left
//                    anchors.right: parent.right
//                    anchors.topMargin: -15
//                    font.bold: true
//                    horizontalAlignment: Text.AlignHCenter
//                    verticalAlignment: Text.AlignVCenter
//                    renderType: Text.NativeRendering
//                    color: fandidYellow
//                    font.pointSize: bottomIndicatorSize
//                }
        }

        MePageTopIndicator {
            id: mePageTopIndicator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.bottom
        }
    }

    function moveFeedToBeginning()
    {
        switch(swipeViewMePage.currentIndex)
        {
            case 0:
                notificationsFeed.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
                break
            case 1:
                yourPostsLoader.item.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
                break
            case 2:
                followedPostsLoader.item.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
                break
            case 3:
                joinedGroupsLoader.item.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
                break
        }
    }

    function refreshNotifications()
    {
        notificationsFeed.refreshFeed()
    }

    SwipeView {
        id: swipeViewMePage
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: mePageTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: mePageTopIndicator.mePageTopIndicatorHeight + 10
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        spacing: 20
        onCurrentIndexChanged: mePageTopIndicator.colorButton(currentIndex)

        property bool yourPostsLoaded: false
        property bool followedPostsLoaded: false
        property bool joinedGroupsLoaded: false

        //Loaded by default
        MultiFeed{id: notificationsFeed; type: RequestType.NOTIFICATIONS}

        Loader {
            id: yourPostsLoader
            active: swipeViewMePage.currentIndex === 1 || swipeViewMePage.yourPostsLoaded
            sourceComponent: MultiFeed{type: RequestType.MYPOSTS}
            onLoaded: swipeViewMePage.yourPostsLoaded = true
        }

        Loader {
            id: followedPostsLoader
            active: swipeViewMePage.currentIndex === 2 || swipeViewMePage.followedPostsLoaded
            sourceComponent: MultiFeed{type: RequestType.FOLLOWEDPOSTS}
            onLoaded: swipeViewMePage.followedPostsLoaded = true
        }

        Loader {
            id: joinedGroupsLoader
            active: swipeViewMePage.currentIndex === 3|| swipeViewMePage.joinedGroupsLoaded
            sourceComponent: MultiFeed{type: RequestType.JOINEDGROUPS}
            onLoaded: swipeViewMePage.joinedGroupsLoaded = true
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
