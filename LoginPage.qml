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
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.12

Item {
    anchors.fill: parent

    property int buttonSize: 20

    Flickable {
        anchors.fill: parent
        contentHeight: window.width * 2

        Image {
            id: image
            height: window.height / 5
            anchors.left: parent.left
            anchors.right: parent.right
            source: "Assets/Images/logocolored.png"
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 30
            fillMode: Image.PreserveAspectFit
        }

        Label {
            id: label
            color: globalTextColor
            text: qsTr("Login")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: image.bottom
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.topMargin: 30
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            font.pointSize: 20
            renderType: Text.NativeRendering
        }

        TextField {
            id: usernameTextField
            inputMethodHints: Qt.ImhNoAutoUppercase
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: label.bottom
            anchors.topMargin: 30
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 13
            renderType: Text.NativeRendering
            placeholderText: qsTr("Username")
            Material.accent: fandidYellowDarker

//            background: Rectangle {
//                id: usernameTextFieldBackground
//                implicitWidth: window.width - 10
//                implicitHeight: platformIsMobile ? 20 : 40
//                color: globalBackgroundDarker
//                radius: 20
//            }
        }

        TextField {
            id: passwordTextField
            echoMode: TextInput.Password
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: usernameTextField.bottom
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 30
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: usernameTextField.font.pointSize
            renderType: Text.NativeRendering
            placeholderText: qsTr("Password")
            Material.accent: fandidYellowDarker

//            background: Rectangle {
//                id: passwordTextFieldBackground
//                implicitWidth: window.width - 10
//                implicitHeight: platformIsMobile ? 20 : 40
//                color: globalBackgroundDarker
//                radius: 20
//            }
        }

        Text {
            id: rulesLink
            text: "<a href='" + linkRules + "'>Read our rules</a>"
            linkColor: fandidYellow
            anchors.top: passwordTextField.bottom
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.RichText
            renderType: Text.NativeRendering
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: usernameTextField.font.pointSize
            font.underline: true
            onLinkActivated: Qt.openUrlExternally(link)
        }

        CheckBox {
            id: rulesCheckBox
            text: qsTr("I agree to the rules")
            anchors.top: rulesLink.bottom
            anchors.left: parent.left
            anchors.leftMargin: window.width / 2 - width / 2
            anchors.topMargin: 30
            font.pointSize: usernameTextField.font.pointSize
            Material.accent: fandidYellowDarker

//            indicator: Rectangle {
//                id: outer1
//                implicitWidth: 26
//                implicitHeight: 26
//                x: parent.leftPadding
//                y: parent.height / 2 - height / 2
//                radius: 3
//                border.color: parent.down ? fandidYellowDarker : fandidYellow

//                Rectangle {
//                    width: 14
//                    height: 14
//                    x: 6
//                    y: 6
//                    radius: 2
//                    color: parent.border.color
//                    visible: parent.parent.checked
//                }
//            }

//            contentItem: Text {
//                anchors.left: outer1.right
//                anchors.leftMargin: 10
//                text: parent.text
//                font: parent.font
//                opacity: enabled ? 1.0 : 0.3
//                color: parent.down ? globalTextColorDarker : globalTextColor
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.horizontalAlignment
//            }
        }

        CheckBox {
            id: rememberMeCheckBox
            text: qsTr("Remember me")
            anchors.top: rulesCheckBox.bottom
            anchors.left: parent.left
            anchors.leftMargin: rulesCheckBox.anchors.leftMargin
            anchors.topMargin: 30
            font.pointSize: usernameTextField.font.pointSize
            Material.accent: fandidYellowDarker

//            indicator: Rectangle {
//                id: outer2
//                implicitWidth: 26
//                implicitHeight: 26
//                x: parent.leftPadding
//                y: parent.height / 2 - height / 2
//                radius: 3
//                border.color: parent.down ? fandidYellowDarker : fandidYellow

//                Rectangle {
//                    width: 14
//                    height: 14
//                    x: 6
//                    y: 6
//                    radius: 2
//                    color: parent.border.color
//                    visible: parent.parent.checked
//                }
//            }

//            contentItem: Text {
//                anchors.left: outer2.right
//                anchors.leftMargin: 10
//                text: parent.text
//                font: parent.font
//                opacity: enabled ? 1.0 : 0.3
//                color: parent.down ? globalTextColorDarker : globalTextColor
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.horizontalAlignment
//            }
        }

        RoundButton {
            id: button
            width: implicitContentWidth + 50
            height: implicitContentHeight + 20
            text: qsTr("Login")
            anchors.top: rememberMeCheckBox.bottom
            font.pointSize: buttonSize
            font.bold: true
            font.capitalization: Font.MixedCase
            display: AbstractButton.TextOnly
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            Material.background: fandidYellowDarker

            onClicked:
            {
                if (rulesCheckBox.checked && usernameTextField.length > 0 && passwordTextField.length > 0)
                {
                    userToken = globalBackend.logIn(usernameTextField.text, passwordTextField.text, rememberMeCheckBox.checked)

                    if (userToken.length != 0)
                    {
                        mainStackView.pop()
                        loginPage.active = false;
                        launchMainView()
                    }
                    else
                        messageDialogLoginFailure.visible = true
                }

                else
                {
                    messageDialogRequirements.visible = true
                }
            }

//            background: Rectangle {
//                implicitWidth: loginButtonText.contentWidth + 50
//                implicitHeight: loginButtonText.contentHeight
//                color: parent.down ? Qt.darker(fandidYellowDarker, 1.5) : fandidYellowDarker
//                radius: 20
//            }

//            contentItem: Text {
//                id: loginButtonText
//                text: parent.text
//                font: parent.font
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                color: parent.down ? globalTextColorDarker : globalTextColor
//            }
        }
    }

    MessageDialog {
        id: messageDialogRequirements
        title: "Warning"
        text: "Please fill in your username and password and agree to our rules."
        icon: StandardIcon.Warning
        visible: false
    }

    MessageDialog {
        id: messageDialogLoginFailure
        title: "Failure"
        text: "Login failed"
        detailedText: "The username or password is incorrect"
        icon: StandardIcon.Critical
        visible: false
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.1}
}
##^##*/
