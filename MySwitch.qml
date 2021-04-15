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
    focusPolicy: Qt.NoFocus

    contentItem: Text {
        text: parent.text
        font: parent.font
        opacity: enabled ? 1.0 : 0.3
        color: parent.down ? Qt.darker(globalTextColor, 1.5) : globalTextColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: parent.indicator.width + parent.spacing
    }
}
