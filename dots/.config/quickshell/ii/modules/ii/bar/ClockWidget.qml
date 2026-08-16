import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool showDate: Config.options.bar.verbose
    readonly property bool showUnreadCount: Config.options.bar.indicators.notifications.showUnreadCount
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer1
            text: DateTime.longDate
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.colors.colOnLayer1
            text: "•"
        }

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer1
            text: DateTime.time
        }
    }

    Rectangle { // Unread notification badge, overlays the clock's top right corner
        id: notifBadge
        visible: Notifications.unread > 0
        anchors {
            right: rowLayout.right
            top: rowLayout.top
            rightMargin: -implicitWidth
            topMargin: -2
        }
        z: 1

        radius: Appearance.rounding.full
        color: Notifications.silent ? Appearance.colors.colOutline : Appearance.colors.colOnLayer0
        implicitHeight: root.showUnreadCount ? Math.max(badgeText.implicitHeight, badgeText.implicitWidth) : 8
        implicitWidth: root.showUnreadCount ? Math.max(implicitHeight, badgeText.implicitWidth + 4) : 8

        StyledText {
            id: badgeText
            visible: root.showUnreadCount
            anchors.centerIn: parent
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.colors.colLayer0
            text: Notifications.unread
        }
    }

    // MouseArea {
    //     id: mouseArea
    //     anchors.fill: parent
    //     hoverEnabled: !Config.options.bar.tooltips.clickToShow

    //     ClockWidgetPopup {
    //         hoverTarget: mouseArea
    //     }
    // }
}
