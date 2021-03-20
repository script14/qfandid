import QtQuick 2.4
import QtQuick.Controls 2.15

Item {

    id: topItem
    width: platformIsMobile ? 64 : 128
    height: width
    x: window.width / 2 - width / 2

    BusyIndicator {
        id: myLoadingIndicator

        contentItem: Item {
            implicitWidth: topItem.width
            implicitHeight: topItem.height

            Item {
                id: item
                width: topItem.width
                height: topItem.height
                opacity: myLoadingIndicator.running ? 1 : 0

                Behavior on opacity {
                    OpacityAnimator {
                        duration: 250
                    }
                }

                RotationAnimator {
                    target: item
                    running: myLoadingIndicator.visible && myLoadingIndicator.running
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
                        implicitWidth: platformIsMobile ? 7 : 15
                        implicitHeight: implicitWidth
                        radius: 20
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

        Component.onCompleted: removeTimer.running = true

        Timer {
            id: removeTimer
            running: false
            repeat: true
            interval: 100
            onTriggered:
            {
                if (multiFeedListView.unlocked)
                {
                    if (typeof(index) != "undefined")
                    {
                        removeTimer.running = false
                        multiFeed.removePostOrComment(index)
                        myLoadingIndicator.destroy()
                    }
                }
            }
        }
    }
}
