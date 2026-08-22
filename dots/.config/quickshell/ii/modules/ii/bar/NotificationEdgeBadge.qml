import qs.modules.common
import qs.services
import QtQuick

Rectangle { // Unread notification indicator, pinned to the bar's right edge
    id: root

    implicitWidth: 6

    color: Notifications.silent ? Appearance.colors.colOutline : "#b0b0b0"
    visible: opacity > 0
    opacity: Notifications.unread > 0 ? 1 : 0

    Behavior on opacity {
        enabled: !blinkAnim.running
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    SequentialAnimation {
        id: blinkAnim
        loops: 3
        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: 90
        }
        NumberAnimation {
            target: root
            property: "opacity"
            to: 1
            duration: 90
        }
    }

    Connections {
        target: Notifications
        function onNotify(notification) {
            blinkAnim.restart();
        }
    }
}
