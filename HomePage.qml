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

    HomePageTopIndicator {
        id: homePageTopIndicator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        z: 1 //"z" makes it appear above other components
    }

    function movePostFeedToBeginning()
    {
        switch (homePageSwipeView.currentIndex)
        {
            case 0:
                homePageNewLoader.item.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
                break
            case 1:
                homePageHotLoader.item.externMultiFeedListView.positionViewAtIndex(0, ListView.End)
                break
            case 2:
                searchPageLoader.item.movePostFeedToBeginning()
        }
    }

    SwipeView {
        id: homePageSwipeView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: homePageTopIndicator.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 10
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        spacing: 20
        onCurrentIndexChanged: homePageTopIndicator.colorButton(currentIndex)

        //The loaders here are to prevent both the new and hot pages from loading simultaneously
        //These booleans are for keeping the loaders active after they're loaded once
        property bool postFeed0Loaded: false
        property bool postFeed1Loaded: false
        property bool postFeed2Loaded: false

        Loader {
            id: homePageNewLoader
            active: homePageSwipeView.currentIndex === 0 || homePageSwipeView.postFeed0Loaded
            sourceComponent: MultiFeed{type: RequestType.NEW}
            onLoaded: homePageSwipeView.postFeed0Loaded = true
        }

        Loader {
            id: homePageHotLoader
            active: homePageSwipeView.currentIndex === 1 || homePageSwipeView.postFeed1Loaded
            sourceComponent: MultiFeed{type: RequestType.HOT}
            onLoaded: homePageSwipeView.postFeed1Loaded = true
        }

        Loader {
            id: searchPageLoader
            active: homePageSwipeView.currentIndex === 2 || homePageSwipeView.postFeed2Loaded
            sourceComponent: SearchPage{}
            onLoaded: homePageSwipeView.postFeed2Loaded = true
        }
    }
}
