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
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import qFandid.Backend 1.0
import QtQuick.Controls.Material 2.12
import 'Assets/Strings/mystrings.js' as MyStrings

Item {

    //Sizes
    property int optionTextSize: 15
    property int linkTextSize: 15
    property int topMargins: platformIsMobile ? 15 : 30
    property int buttonSize: platformIsMobile ? 13 : 15

    BackEnd {
        id: settingsBackend
    }

    Component.onDestruction:
    {
        focusWindow.focus = true
        globalBackend.saveUserSettings(userSettings)
    }

    Rectangle {
        id: settingsPageTopBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: settingsTitle.contentHeight + 20
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
            id: settingsTitle
            width: window.width / 3
            text: qsTr("Settings")
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

    Flickable {
        id: flickable
        anchors.top: settingsPageTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        contentHeight: window.height * 2

        Label {
            id: appVersionLabel
            anchors.top: parent.top
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            text: "App version: " + MyStrings.appVersion
            color: globalTextColor
            textFormat: Text.PlainText
            renderType: Text.NativeRendering
            font.pointSize: optionTextSize
        }

        RowLayout {
            id: imgsOnlyInPostRowLayout
            anchors.top: appVersionLabel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Load images only in post page")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                id: loadImgsOnlyInPost
                checked: userSettings["loadImagesOnlyInPostPage"]
                onCheckedChanged:
                {
                    userSettings["loadImagesOnlyInPostPage"] = checked
                    if (userSettings["loadImagesOnlyInPostPage"] === false)
                    {
                        userSettings["doNotHideNsfw"] = false
                        doNotHideNsfw.checked = false
                    }
                }
            }
        }

        RowLayout {
            id: matureContentRowLayout
            anchors.top: imgsOnlyInPostRowLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Load mature (NSFW) content")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                id: loadMatureContent
                checked: userInfo["riskLevel"]
                onClicked:
                {
                    //Use reverse bools because the check has not yet propagated
                    if (checked)
                    {
                        checked = false
                        matureContentConfirmation.visible = true
                    }
                    else
                    {
                        userInfo["riskLevel"] = 0
                        globalBackend.setNsfw(userInfo["riskLevel"], userToken)
                    }
                }
            }
        }

        RowLayout {
            id: doNotHideNsfwRowLayout
            anchors.top: matureContentRowLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Do not hide NSFW content")
                color: doNotHideNsfw.enabled ? globalTextColor : globalTextColorDarker
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                id: doNotHideNsfw
                enabled: !loadImgsOnlyInPost.checked && loadMatureContent.checked
                checked: userSettings["doNotHideNsfw"]
                onCheckedChanged: userSettings["doNotHideNsfw"] = checked
            }
        }

        RowLayout {
            id: scrollBarLocationLayout
            anchors.top: doNotHideNsfwRowLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Scroll bar to left (requires restart)")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                checked: userSettings["scrollBarToLeft"]
                onCheckedChanged: userSettings["scrollBarToLeft"] = checked
            }
        }

        RowLayout {
            id: lightModeLayout
            anchors.top: scrollBarLocationLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Light mode (requires restart)")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                checked: userSettings["lightMode"]
                onCheckedChanged: settingsBackend.setLightMode(checked)
            }
        }

        RowLayout {
            id: postStyleLayout
            anchors.top: lightModeLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Minimal post style")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                checked: userSettings["minimalPostStyle"]
                onCheckedChanged: userSettings["minimalPostStyle"] = checked
            }
        }

        RowLayout {
            id: dmNotificationsLayout
            anchors.top: postStyleLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("DM Notifications")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                checked: userSettings["dmNotifications"]
                onCheckedChanged: userSettings["dmNotifications"] = checked
            }
        }

        RowLayout {
            id: commentNotificationsLayout
            anchors.top: dmNotificationsLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Comment Notifications")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            MySwitch {
                checked: userSettings["commentNotifications"]
                onCheckedChanged: userSettings["commentNotifications"] = checked
            }
        }

        RowLayout {
            id: postTextSizeSpinBoxLayout
            anchors.top: commentNotificationsLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10

            Label {
                id: postTextSizeSpinBoxLabel
                Layout.fillWidth: true
                text: qsTr("Post text font size")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            SpinBox {
                id: postFontSizeSpinBox
                implicitWidth: 150
                Material.accent: fandidYellowDarker
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                from: 1
                value: userSettings["postFontSize"]
                onValueChanged: userSettings["postFontSize"] = value
            }
        }

        RowLayout {
            id: commentTextSizeSpinBoxLayout
            anchors.top: postTextSizeSpinBoxLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10

            Label {
                id: commentTextSizeSpinBoxLabel
                Layout.fillWidth: true
                text: qsTr("Comment text font size")
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            SpinBox {
                id: commentFontSizeSpinBox
                implicitWidth: 150
                Material.accent: fandidYellowDarker
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                from: 1
                value: userSettings["commentFontSize"]
                onValueChanged: userSettings["commentFontSize"] = value
            }
        }

        RowLayout {
            id: cacheRowLayout
            anchors.top: commentTextSizeSpinBoxLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Label {
                id: cacheLabel
                text: "Image cache: " + settingsBackend.getCacheSize()
                Layout.fillWidth: true
                color: globalTextColor
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font.pointSize: optionTextSize
            }

            Button {
                id: buttonCache
                text: qsTr("Clear")
                font.bold: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked:
                {
                    settingsBackend.clearCache()
                    cacheLabel.text = "Image cache: 0.00 MB"
                }

                background: Rectangle {
                    implicitWidth: buttonCacheText.contentWidth + 50
                    implicitHeight: buttonCacheText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: buttonCacheText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }
        }

        RowLayout {
            id: buttonsRowLayout
            anchors.top: cacheRowLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Button {
                id: buttonRules
                text: qsTr("Rules")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: Qt.openUrlExternally(linkRules)

                background: Rectangle {
                    implicitWidth: window.width / 3 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: rulesButtonText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: rulesButtonText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }

            Button {
                id: buttonChangelog
                text: qsTr("Changelog")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: mainStackView.push("InfoPage.qml", {"imageSource": "Assets/Images/logocolored.png", "title": "Changelog", "textContent": MyStrings.changelog})

                background: Rectangle {
                    implicitWidth: window.width / 3 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: changelogButtonText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: changelogButtonText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }

            Button {
                id: buttonCredits
                text: qsTr("Credits")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: mainStackView.push("InfoPage.qml", {"imageSource": "Assets/Images/logocolored.png", "title": "Credits", "textContent": MyStrings.credits})

                background: Rectangle {
                    implicitWidth: window.width / 3 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: creditsButtonText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: creditsButtonText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }
        }

        RowLayout {
            id: aboutButtonsRowLayout
            anchors.top: buttonsRowLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Button {
                id: buttonaboutqFandid
                text: qsTr("About qFandid")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: mainStackView.push("InfoPage.qml", {"imageSource": "Assets/Images/logocolored.png", "title": "About qFandid", "textContent": MyStrings.aboutqFandid})

                background: Rectangle {
                    implicitWidth: window.width / 3 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: aboutButtonText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: aboutButtonText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }

            Button {
                id: buttonaboutQt
                text: qsTr("About Qt")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: mainStackView.push("InfoPage.qml", {"imageSource": "Assets/Images/Qt.svg", "title": "About Qt", "textContent": MyStrings.aboutQt})

                background: Rectangle {
                    implicitWidth: window.width / 3 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: qtButtonText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: qtButtonText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }

            Button {
                id: buttonGPL
                text: qsTr("About GPL")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: mainStackView.push("InfoPage.qml", {"imageSource": "Assets/Images/gpl-v3-logo.svg", "title": "GPL license", "textContent": globalBackend.readText(":/COPYING")})

                background: Rectangle {
                    implicitWidth: window.width / 3 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: buttonGPLText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: buttonGPLText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }
        }

        RowLayout {
            id: modButtonsRowLayout
            anchors.top: aboutButtonsRowLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            visible: userInfo["power"] >= 4

            Button {
                id: buttonModLog
                text: qsTr("Mod Log")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: mainStackView.push("ModLog.qml")

                background: Rectangle {
                    implicitWidth: window.width / 2 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: modlogButtonText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: modlogButtonText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }

            Button {
                id: buttonJoinGroups
                text: qsTr("Join groups")
                font.bold: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: buttonSize
                font.capitalization: Font.MixedCase
                onClicked: settingsBackend.modJoinGroups(userToken)

                background: Rectangle {
                    implicitWidth: window.width / 2 - parent.parent.anchors.leftMargin - parent.parent.anchors.rightMargin
                    implicitHeight: joinGroupsButtonText.contentHeight
                    color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                    radius: 20
                }

                contentItem: Text {
                    id: joinGroupsButtonText
                    text: parent.text
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
                }
            }
        }

        Rectangle {
            id: patretonLinkRect
            width: window.width - 10
            height: patreonImage.height + patreonText.contentHeight + patreonText.anchors.topMargin
            anchors.top: modButtonsRowLayout.visible ? modButtonsRowLayout.bottom : aboutButtonsRowLayout.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            color: "transparent"

            Image {
                id: patreonImage
                height: sourceSize.height * width / sourceSize.width
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                width: parent.width / 1.5
                source: "Assets/Images/patreon-logo.svg"
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: patreonText
                width: parent.width - 20
                text: qsTr("Donate on Patreon to keep Fandid alive\n<font color='#FFC20B'>www.patreon.com/fandidapp</font>")
                anchors.left: parent.left
                anchors.top: patreonImage.bottom
                color: globalTextColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                renderType: Text.NativeRendering
                anchors.leftMargin: 10
                anchors.topMargin: 10
                font.pointSize: linkTextSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://www.patreon.com/fandidapp")
            }
        }

        Rectangle {
            id: discordLinkRect
            width: window.width - 10
            height: discordImage.height + discordText.contentHeight + discordText.anchors.topMargin
            anchors.top: patretonLinkRect.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargins
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            color: "transparent"

            Image {
                id: discordImage
                height: sourceSize.height * width / sourceSize.width
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                width: parent.width / 1.5
                source: "Assets/Images/discord-logo.svg"
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: discordText
                width: parent.width - 20
                text: qsTr("Find us on Discord to learn more about Fandid and contact us directly\n<font color='#FFC20B'>discord.gg/b5cpMnzr3M</font>")
                anchors.left: parent.left
                anchors.top: discordImage.bottom
                color: globalTextColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                renderType: Text.NativeRendering
                anchors.leftMargin: 10
                anchors.topMargin: 10
                font.pointSize: linkTextSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://discord.gg/b5cpMnzr3M")
            }
        }

        Button {
            id: buttonLogout
            text: qsTr("Sign out")
            font.bold: true
            anchors.top: discordLinkRect.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: topMargins
            font.pointSize: buttonSize
            font.capitalization: Font.MixedCase
            onClicked:
            {
                globalBackend.logout()
                globalBackend.restartProgram()
            }

            background: Rectangle {
                implicitWidth: logoutButtonText.contentWidth + 50
                implicitHeight: logoutButtonText.contentHeight
                color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
                radius: 20
            }

            contentItem: Text {
                id: logoutButtonText
                text: parent.text
                font: parent.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: parent.down ? Qt.darker(buttonColor, 1.2) : buttonColor
            }
        }
    }

    MessageDialog {
        id: matureContentConfirmation
        visible: false
        title: "Confirm action"
        text: "I am at least 18 years old and want to enable mature (NSFW) content"
        icon: StandardIcon.Question
        standardButtons: StandardButton.Yes | StandardButton.No
        onNo: visible = false
        onYes:
        {
            userInfo["riskLevel"] = 1
            globalBackend.setNsfw(userInfo["riskLevel"], userToken)
            loadMatureContent.checked = true
        }
    }
}
