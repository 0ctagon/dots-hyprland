import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.widgets

/**
 * Small VPN indicator meant to be anchored over a corner of another icon.
 */
Loader {
    id: root

    property real baseIconSize: Appearance.font.pixelSize.larger
    property color color: Appearance.colors.colOnLayer0

    active: Network.vpn

    sourceComponent: Rectangle { // Disc keeps the badge readable over the glyph underneath
        implicitWidth: Math.max(badgeSymbol.implicitWidth, badgeSymbol.iconSize) + 3
        implicitHeight: implicitWidth
        radius: width / 2
        color: Appearance.colors.colLayer0

        MaterialSymbol {
            id: badgeSymbol
            anchors.centerIn: parent
            text: "vpn_lock"
            fill: 1
            iconSize: Math.round(root.baseIconSize * 0.6)
            color: root.color
        }
    }
}
