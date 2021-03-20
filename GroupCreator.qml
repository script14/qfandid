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
import RequestType 1.0
import qFandid.Backend 1.0
import QtQuick.Controls.Material 2.12

Item {

    //Sizes
    property int buttonTextSize: 18

    property int nameCharacterLimit: 31
    property int descriptionCharacterLimit: 500

    Component.onDestruction: focusWindow.focus = true

    BackEnd {
        id: groupCreatorBackend
    }

    Rectangle {
        id: groupCreatorTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: groupCreatorTopBarTitle.contentHeight + 20
        color: globalBackgroundDarker
        z: 1

        Label {
            id: backButton
            text: ic_arrow_down
            color: globalTextColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 20
            rotation: 90
            renderType: Text.NativeRendering
            font.family: "FandidIcons"
            font.pointSize: 25

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mainStackView.pop()
            }
        }

        Label {
            id: groupCreatorTopBarTitle
            width: window.width - 50
            text: qsTr("Create a new group")
            color: globalTextColor
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.NativeRendering
        }
    }

    TextField {
        id: groupNameTextField
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: groupCreatorTopBar.bottom
        anchors.topMargin: 30
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 15
        renderType: Text.NativeRendering
        placeholderText: qsTr("Group name")
        Material.accent: fandidYellowDarker
        rightPadding: nameCharLimit.contentWidth + 20

//        background: Rectangle {
//            id: groupNameTextFieldBackground
//            implicitWidth: window.width - 10
//            implicitHeight: platformIsMobile ? 20 : 40
//            color: globalBackgroundDarker
//            radius: 20
//        }

        Label {
            id: nameCharLimit
            text: "0/" + nameCharacterLimit
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            color: globalTextColorDarker
            font.pointSize: 15
        }

        onTextChanged:
        {
            if (length > nameCharacterLimit)
                remove(nameCharacterLimit, length)
            nameCharLimit.text = length + "/" + nameCharacterLimit
        }

        onEditingFinished: focusWindow.focus = true
    }

    ScrollView {
        id: scrollView
        anchors.top: groupNameTextField.bottom
        anchors.topMargin: 20
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        height: window.height / 2 - groupCreatorTopBar.height - groupNameTextField.height

        TextArea {
            id: groupDescriptionTextArea
            placeholderText: qsTr("Group description")
            font.pointSize: 13
            selectByKeyboard: true
            selectByMouse: platformIsMobile ? false : true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            renderType: Text.NativeRendering
            leftPadding: 10
            rightPadding: 10
            Material.accent: fandidYellowDarker

            background: Rectangle {
                implicitWidth: scrollView.width
                implicitHeight: groupDescriptionTextArea.contentHeight
                color: globalBackgroundDarker
                radius: 20
            }

            Label {
                id: descriptionCharLimit
                text: "0/" + descriptionCharacterLimit
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 10
                anchors.bottomMargin: 10
                renderType: Text.NativeRendering
                color: globalTextColorDarker
                font.pointSize: 15
            }

            onTextChanged:
            {
                if (length > descriptionCharacterLimit)
                    remove(descriptionCharacterLimit, length)
                descriptionCharLimit.text = length + "/" + descriptionCharacterLimit
            }

            onEditingFinished: focusWindow.focus = true
        }
    }

    MySwitch {
        id: nsfwSwitch
        text: qsTr("NSFW")
        font.pointSize: 15
        anchors.top: scrollView.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        visible: userInfo["riskLevel"] > 0
    }

    RoundButton {
        id: createButton
        width: implicitContentWidth + 50
        height: implicitContentHeight + 20
        anchors.top: nsfwSwitch.visible ? nsfwSwitch.bottom : scrollView.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Create")
        font.pointSize: buttonTextSize
        font.capitalization: Font.MixedCase
        font.bold: true
        Material.background: fandidYellowDarker
        enabled: groupNameTextField.text.length !== 0 && groupDescriptionTextArea.text.length !== 0
        onClicked: groupCreatorBackend.createGroup(groupNameTextField.text, groupDescriptionTextArea.text, nsfwSwitch.checked, userToken)

//        background: Rectangle {
//            implicitWidth: createButtonText.contentWidth + 50
//            implicitHeight: createButtonText.contentHeight
//            color: enabled ? (parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker) : darkenedButton
//            radius: 20
//        }

//        contentItem: Text {
//            id: createButtonText
//            text: parent.text
//            font: parent.font
//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
//            color: parent.down ? Qt.darker(globalTextColor, 1.2) : globalTextColor
//        }
    }

    Connections {
        target: groupCreatorBackend
        function onGroupCreated()
        {
            globalBackend.makeNotification("Group created", "Group created")
            mainStackView.pop()
        }
    }
}
