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
import QtQuick.Controls.Material 2.12

Switch {
    Material.accent: fandidYellowDarker

//    indicator: Rectangle {
//        implicitWidth: platformIsMobile ? 50 : 60
//        implicitHeight: platformIsMobile ? 15 : 26
//        x: parent.leftPadding
//        y: parent.height / 2 - height / 2
//        radius: 13
//        Material.accent: fandidYellowDarker

//        Rectangle {
//            x: parent.parent.checked ? parent.width - width : 0
//            width: 26
//            height: parent.implicitHeight
//            radius: 13
//            color: parent.parent.down ? "#cccccc" : globalTextColor

//            Behavior on x
//            {
//                NumberAnimation { duration: 100 }
//            }
//        }
//    }

    contentItem: Text {
        text: parent.text
        font: parent.font
        opacity: enabled ? 1.0 : 0.3
        color: parent.down ? Qt.darker(globalTextColor, 1.5) : globalTextColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: parent.indicator.width + parent.spacing
    }
}
