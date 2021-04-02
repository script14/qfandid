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
import QtWebView 1.15

Item {
    anchors.fill: parent

    property int buttonSize: 20
    property int usernameCharacterLimit: 20
    property int passwordCharacterLimit: 64

    Flickable {
        anchors.fill: parent
        contentHeight: window.width * 3

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
            text: qsTr("Register")
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
            rightPadding: nameCharLimit.contentWidth + 20
            leftPadding: nameCharLimit.contentWidth + 20
            Material.accent: fandidYellowDarker

            Label {
                id: nameCharLimit
                text: "0/" + usernameCharacterLimit
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                color: globalTextColorDarker
                font.pointSize: 15
            }

            onTextChanged:
            {
                if (length > usernameCharacterLimit)
                    remove(usernameCharacterLimit, length)
                nameCharLimit.text = length + "/" + usernameCharacterLimit
            }
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
            rightPadding: passwordCharLimit.contentWidth + 20
            leftPadding: nameCharLimit.contentWidth + 20
            Material.accent: fandidYellowDarker

            Label {
                id: passwordCharLimit
                text: "0/" + passwordCharacterLimit
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                color: globalTextColorDarker
                font.pointSize: 15
            }

            onTextChanged:
            {
                if (length > passwordCharacterLimit)
                    remove(passwordCharacterLimit, length)
                passwordCharLimit.text = length + "/" + passwordCharacterLimit
            }
        }

        TextField {
            id: confirmPasswordTextField
            echoMode: TextInput.Password
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: passwordTextField.bottom
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 30
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: usernameTextField.font.pointSize
            renderType: Text.NativeRendering
            placeholderText: qsTr("Confirm password")
            rightPadding: confirmPasswordCharLimit.contentWidth + 20
            leftPadding: nameCharLimit.contentWidth + 20
            Material.accent: fandidYellowDarker

            Label {
                id: confirmPasswordCharLimit
                text: "0/" + passwordCharacterLimit
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                color: globalTextColorDarker
                font.pointSize: 15
            }

            onTextChanged:
            {
                if (length > passwordCharacterLimit)
                    remove(passwordCharacterLimit, length)
                confirmPasswordCharLimit.text = length + "/" + passwordCharacterLimit
            }
        }

        Text {
            id: rulesLink
            text: "Read our rules"
            anchors.top: confirmPasswordTextField.bottom
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.RichText
            renderType: Text.NativeRendering
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: usernameTextField.font.pointSize
            font.underline: true
            color: fandidYellow

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally(linkRules)
            }
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
        }

        RoundButton {
            id: registerButton
            width: implicitContentWidth + 50
            height: implicitContentHeight + 20
            text: qsTr("Register")
            anchors.top: rememberMeCheckBox.bottom
            font.pointSize: buttonSize
            font.bold: true
            font.capitalization: Font.MixedCase
            display: AbstractButton.TextOnly
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            Material.background: fandidYellowDarker
            Material.foreground: buttonColor

            onClicked:
            {
                if (!rulesCheckBox.checked || usernameTextField.text.length === 0 || passwordTextField.text.length === 0 || confirmPasswordTextField.text.length === 0)
                {
                    messageDialog.text = "Please fill in your username and password and agree to our rules."
                    messageDialog.visible = true
                }

                else if (usernameTextField.text.length < 3  || passwordTextField.text.length < 3 || confirmPasswordTextField.text.length < 3)
                {
                    messageDialog.text = "Your username and password must be at least 3 characters long"
                    messageDialog.visible = true
                }

                else if (passwordTextField.text !== confirmPasswordTextField.text)
                {
                    messageDialog.text = "The passwords do not match."
                    messageDialog.visible = true
                }

                else
                    webView.runJavaScript("grecaptcha.getResponse()", recaptchaResult)
            }
        }

        RoundButton {
            id: skipButton
            width: implicitContentWidth + 50
            height: implicitContentHeight + 20
            text: qsTr("Skip registration")
            anchors.top: registerButton.bottom
            font.pointSize: buttonSize
            font.bold: true
            font.capitalization: Font.MixedCase
            display: AbstractButton.TextOnly
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            Material.background: fandidYellowDarker
            Material.foreground: buttonColor

            onClicked:
            {
                if (!rulesCheckBox.checked)
                {
                    messageDialog.text = "Please agree to our rules."
                    messageDialog.visible = true
                }
                else
                    webView.runJavaScript("grecaptcha.getResponse()", recaptchaResult)
            }
        }

        WebView {
            id: webView
            anchors.top: skipButton.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 10
            height: window.height / 2
            visible: true
            url: linkRecaptcha
            onLoadingChanged:
            {
                if (loadRequest.status === WebView.LoadSucceededStatus)
                {
                    runJavaScript("document.body.style.backgroundColor = '" + globalBackground + "'")
                }
            }
        }
    }

    function recaptchaResult(token)
    {
        if (token.length === 0)
        {
            messageDialog.text = "Please complete the recaptcha."
            messageDialog.visible = true
        }
        else
        {
            var response = globalBackend.registerAccount(usernameTextField.text, passwordTextField.text, token, rememberMeCheckBox.checked)
            if (response.length !== 0)
            {
                userToken = response
                mainStackView.pop()
                loginPage.active = false
                launchMainView()
            }
            else
            {
                messageDialog.text = "Username is already taken."
                messageDialog.visible = true
            }
        }
    }

    MessageDialog {
        id: messageDialog
        title: "Error"
        text: ""
        icon: StandardIcon.Warning
        visible: false
    }

}
