pragma Singleton

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string killDialogQmlPath: FileUtils.trimFileProtocol(Quickshell.shellPath("killDialog.qml"))

    function load() {
        // dummy to force init
    }

    Connections {
        target: Config
        function onReadyChanged() {
            if (Config.ready) checkConflictsProc.running = true
        }
    }

    Process {
        id: checkConflictsProc
        // kded6 only conflicts when it actually holds the StatusNotifierWatcher name.
        // Its other modules (bluetooth, network, ...) are harmless, so don't report it
        // as a conflict just for being alive.
        command: ["bash", "-c", `
            tray_conflict=""
            owner_pid=$(busctl --user list --no-pager 2>/dev/null | awk '$1 == "org.kde.StatusNotifierWatcher" { print $2; exit }')
            if [ -n "$owner_pid" ] && [ "$owner_pid" != "-" ]; then
                case " $(pidof kded6) " in *" $owner_pid "*) tray_conflict="$owner_pid";; esac
            fi
            echo "$tray_conflict;$(pidof mako dunst)"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text;
                const conflictingTrays = output.split(";")[0].trim().length > 0;
                const conflictingNotifications = output.split(";")[1].trim().length > 0;
                var openDialog = false;
                if (conflictingTrays) {
                    if (!Config.options.conflictKiller.autoKillTrays) openDialog = true;
                    else Quickshell.execDetached(["killall", "kded6"])
                }
                if (conflictingNotifications) {
                    if (!Config.options.conflictKiller.autoKillNotificationDaemons) openDialog = true;
                    else Quickshell.execDetached(["killall", "mako", "dunst"])
                }
                if (openDialog) {
                    Quickshell.execDetached(["qs", "-p", root.killDialogQmlPath])
                }
            }
        }
    }
}
