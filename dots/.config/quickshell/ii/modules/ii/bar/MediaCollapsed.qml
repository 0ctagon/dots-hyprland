pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.mediaControls

RippleButton { // Single media button that reveals the media controls in a popup
    id: root
    property bool popupOpen: false
    property bool hoverOpen: false
    property bool containsMouse: hovered
    readonly property bool popupVisible: root.popupOpen || root.hoverOpen
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property bool playing: activePlayer?.isPlaying ?? false
    readonly property var meaningfulPlayers: MprisController.meaningfulPlayers

    toggled: root.popupOpen || root.hoverOpen
    downAction: () => root.popupOpen = !root.popupOpen

    implicitWidth: 24
    implicitHeight: 24
    background.implicitWidth: 24
    background.implicitHeight: 24
    background.anchors.centerIn: this
    colBackgroundToggled: Appearance.colors.colSecondaryContainer
    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
    colRippleToggled: Appearance.colors.colSecondaryContainerActive

    contentItem: MaterialSymbol {
        anchors.centerIn: parent
        iconSize: Appearance.font.pixelSize.larger
        fill: root.playing ? 1 : 0
        text: !root.activePlayer ? "music_off" : root.playing ? "graphic_eq" : "music_note"
        horizontalAlignment: Text.AlignHCenter
        color: root.toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer0
    }

    onPopupOpenChanged: {
        if (root.popupOpen) focusGrab.active = true;
    }

    onPopupVisibleChanged: { // Only feed the visualizer while the popup is up
        if (root.popupVisible) Cava.ref();
        else Cava.unref();
    }

    onHoveredChanged: {
        if (root.hovered) {
            hoverCloseTimer.stop();
            root.hoverOpen = true;
        } else {
            hoverCloseTimer.restart();
        }
    }

    Timer { // Grace period so the pointer can travel from the button into the popup
        id: hoverCloseTimer
        interval: 300
        onTriggered: {
            if (!root.hovered && !popupMouseArea.containsMouse)
                root.hoverOpen = false;
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: false
        windows: [popupMouseArea.QsWindow?.window]
        onCleared: root.popupOpen = false
    }

    StyledPopup {
        id: mediaPopup
        hoverTarget: root
        active: root.popupOpen || root.hoverOpen

        MouseArea {
            id: popupMouseArea
            anchors.centerIn: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            implicitWidth: mediaColumnLayout.implicitWidth
            implicitHeight: mediaColumnLayout.implicitHeight
            onContainsMouseChanged: {
                if (containsMouse)
                    hoverCloseTimer.stop();
                else
                    hoverCloseTimer.restart();
            }

            ColumnLayout {
                id: mediaColumnLayout
                anchors.centerIn: parent
                spacing: 14

                StyledPopupHeaderRow {
                    icon: "music_note"
                    label: Translation.tr("Media")
                }

                Repeater {
                    model: ScriptModel {
                        values: root.meaningfulPlayers
                    }
                    delegate: PlayerControl {
                        required property MprisPlayer modelData
                        player: modelData
                        visualizerPoints: Cava.values
                        implicitWidth: Appearance.sizes.mediaControlsWidth
                        implicitHeight: Appearance.sizes.mediaControlsHeight
                        radius: Appearance.rounding.small
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.meaningfulPlayers.length === 0
                    text: Translation.tr("No active player")
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
