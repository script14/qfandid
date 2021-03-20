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

Item {

    property alias indicatorWidth: topItem.width
    property alias indicatorHeight: topItem.height

    id: topItem
    width: 64
    height: 64

    BusyIndicator {
        id: myBusyIndicator

        contentItem: Item {
            implicitWidth: topItem.width
            implicitHeight: topItem.height

            Item {
                id: item
                x: parent.width / 2 - 32
                y: parent.height / 2 - 32
                width: topItem.width
                height: topItem.height
                opacity: myBusyIndicator.running ? 1 : 0

                Behavior on opacity {
                    OpacityAnimator {
                        duration: 250
                    }
                }

                RotationAnimator {
                    target: item
                    running: myBusyIndicator.visible && myBusyIndicator.running
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 2000
                }

                Repeater {
                    id: repeater
                    model: 6

                    Rectangle {
                        x: item.width / 2 - width / 2
                        y: item.height / 2 - height / 2
                        implicitWidth: 10
                        implicitHeight: 10
                        radius: 7
                        color: fandidYellowDarker
                        transform: [
                            Translate {
                                y: -Math.min(item.width, item.height) * 0.5 + 5
                            },
                            Rotation {
                                angle: index / repeater.count * 360
                                origin.x: 5
                                origin.y: 5
                            }
                        ]
                    }
                }
            }
        }
    }
}
