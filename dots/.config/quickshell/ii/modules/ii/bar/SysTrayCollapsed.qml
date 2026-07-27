import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs.services
import qs.modules.common
import qs.modules.common.widgets

RippleButton { // Single tray button that reveals all tray items in a popup
    id: root
    property bool popupOpen: false
    property bool hoverOpen: false
    property var activeMenu: null
    property bool containsMouse: hovered

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
        text: "widgets"
        horizontalAlignment: Text.AlignHCenter
        color: root.toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer0
    }

    onPopupOpenChanged: {
        if (root.popupOpen) focusGrab.active = true;
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
            if (!root.hovered && !popupMouseArea.containsMouse && !root.activeMenu)
                root.hoverOpen = false;
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: false
        windows: [popupMouseArea.QsWindow?.window, root.activeMenu]
        onCleared: {
            root.popupOpen = false;
            if (root.activeMenu) {
                root.activeMenu.close();
                root.activeMenu = null;
            }
        }
    }

    StyledPopup {
        id: trayPopup
        hoverTarget: root
        active: root.popupOpen || root.hoverOpen

        MouseArea {
            id: popupMouseArea
            anchors.centerIn: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            implicitWidth: trayColumnLayout.implicitWidth
            implicitHeight: trayColumnLayout.implicitHeight
            onContainsMouseChanged: {
                if (containsMouse)
                    hoverCloseTimer.stop();
                else
                    hoverCloseTimer.restart();
            }

            ColumnLayout {
                id: trayColumnLayout
                anchors.centerIn: parent
                spacing: 14

                StyledPopupHeaderRow {
                    icon: "widgets"
                    label: Translation.tr("System tray")
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    visible: SystemTray.items.values.length === 0
                    text: Translation.tr("Empty")
                    color: Appearance.colors.colSubtext
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Repeater {
                        model: ScriptModel {
                            values: SystemTray.items.values
                        }

                        delegate: SysTrayItem {
                            required property SystemTrayItem modelData
                            item: modelData
                            onMenuClosed: {
                                focusGrab.active = false;
                                hoverCloseTimer.restart();
                            }
                            onMenuOpened: qsWindow => {
                                if (root.activeMenu && root.activeMenu !== qsWindow && typeof root.activeMenu.close === "function")
                                    root.activeMenu.close();
                                root.activeMenu = qsWindow;
                                focusGrab.active = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
