pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions

/**
 * Audio visualizer data from cava, shared between all consumers.
 * Consumers call ref() when they start needing values and unref() when they stop,
 * so the cava process only runs while something is actually showing a visualizer.
 */
Singleton {
    id: root
    property int refCount: 0
    readonly property bool active: refCount > 0
    property list<real> values: []

    function ref() {
        root.refCount++;
    }

    function unref() {
        root.refCount = Math.max(0, root.refCount - 1);
    }

    Process {
        id: cavaProc
        running: root.active
        onRunningChanged: {
            if (!cavaProc.running) {
                root.values = [];
            }
        }
        command: ["cava", "-p", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/cava/raw_output_config.txt`]
        stdout: SplitParser {
            onRead: data => {
                // Parse `;`-separated values into the values array
                let points = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p));
                root.values = points;
            }
        }
    }
}
