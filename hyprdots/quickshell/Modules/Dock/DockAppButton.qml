import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    clip: false
    property var appData
    property var contextMenu: null
    property var dockApps: null
    property int index: -1
    property bool longPressing: false
    property bool dragging: false
    property point dragStartPos: Qt.point(0, 0)
    property point dragOffset: Qt.point(0, 0)
    property int targetIndex: -1
    property int originalIndex: -1
    property bool showWindowTitle: false
    property string windowTitle: ""
    property bool isHovered: mouseArea.containsMouse && !dragging
    property bool showTooltip: mouseArea.containsMouse && !dragging
    property bool isWindowFocused: {
        if (!appData) {
            return false
        }

        if (appData.type === "window") {
            const toplevel = getToplevelObject()
            if (!toplevel) {
                return false
            }
            return toplevel.activated
        } else if (appData.type === "grouped") {
            // For grouped apps, check if any window is focused
            const allToplevels = ToplevelManager.toplevels.values
            for (let i = 0; i < allToplevels.length; i++) {
                const toplevel = allToplevels[i]
                if (toplevel.appId === appData.appId && toplevel.activated) {
                    return true
                }
            }
        }

        return false
    }
    property string tooltipText: {
        if (!appData) {
            return ""
        }

        if ((appData.type === "window" && showWindowTitle) || (appData.type === "grouped" && appData.windowTitle)) {
            const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
            const appName = desktopEntry && desktopEntry.name ? desktopEntry.name : appData.appId
            const title = appData.type === "window" ? windowTitle : appData.windowTitle
            return appName + (title ? " • " + title : "")
        }

        if (!appData.appId) {
            return ""
        }

        const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
        return desktopEntry && desktopEntry.name ? desktopEntry.name : appData.appId
    }

    width: 40
    height: 40

    function getToplevelObject() {
        if (!appData) {
            return null
        }

        const sortedToplevels = CompositorService.sortedToplevels
        if (!sortedToplevels) {
            return null
        }

        if (appData.type === "window") {
            if (appData.uniqueId) {
                for (var i = 0; i < sortedToplevels.length; i++) {
                    const toplevel = sortedToplevels[i]
                    const checkId = toplevel.title + "|" + (toplevel.appId || "") + "|" + i
                    if (checkId === appData.uniqueId) {
                        return toplevel
                    }
                }
            }

            if (appData.windowId !== undefined && appData.windowId !== null && appData.windowId >= 0) {
                if (appData.windowId < sortedToplevels.length) {
                    return sortedToplevels[appData.windowId]
                }
            }
        } else if (appData.type === "grouped") {
            if (appData.windowId !== undefined && appData.windowId !== null && appData.windowId >= 0) {
                if (appData.windowId < sortedToplevels.length) {
                    return sortedToplevels[appData.windowId]
                }
            }
        }

        return null
    }

    function getGroupedToplevels() {
        if (!appData || appData.type !== "grouped") {
            return []
        }

        const toplevels = []
        const allToplevels = ToplevelManager.toplevels.values
        for (let i = 0; i < allToplevels.length; i++) {
            const toplevel = allToplevels[i]
            if (toplevel.appId === appData.appId) {
                toplevels.push(toplevel)
            }
        }
        return toplevels
    }
    onIsHoveredChanged: {
        if (isHovered) {
            exitAnimation.stop()
            if (!bounceAnimation.running)
                bounceAnimation.restart()
        } else {
            bounceAnimation.stop()
            exitAnimation.restart()
        }
    }

    SequentialAnimation {
        id: bounceAnimation

        running: false

        NumberAnimation {
            target: translateY
            property: "y"
            to: -10
            duration: Anims.durShort
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Anims.emphasizedAccel
        }

        NumberAnimation {
            target: translateY
            property: "y"
            to: -8
            duration: Anims.durShort
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Anims.emphasizedDecel
        }
    }

    NumberAnimation {
        id: exitAnimation

        running: false
        target: translateY
        property: "y"
        to: 0
        duration: Anims.durShort
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anims.emphasizedDecel
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
        border.width: 2
        border.color: Theme.primary
        visible: dragging
        z: -1
    }

    Timer {
        id: longPressTimer

        interval: 500
        repeat: false
        onTriggered: {
            if (appData && appData.isPinned) {
                longPressing = true
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        anchors.bottomMargin: -20
        hoverEnabled: true
        cursorShape: longPressing ? Qt.DragMoveCursor : Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: mouse => {
                       if (mouse.button === Qt.LeftButton && appData && appData.isPinned) {
                           dragStartPos = Qt.point(mouse.x, mouse.y)
                           longPressTimer.start()
                       }
                   }
        onReleased: mouse => {
                        longPressTimer.stop()
                        if (longPressing) {
                            if (dragging && targetIndex >= 0 && targetIndex !== originalIndex && dockApps) {
                                dockApps.movePinnedApp(originalIndex, targetIndex)
                            }

                            longPressing = false
                            dragging = false
                            dragOffset = Qt.point(0, 0)
                            targetIndex = -1
                            originalIndex = -1
                        }
                    }
        onPositionChanged: mouse => {
                               if (longPressing && !dragging) {
                                   const distance = Math.sqrt(Math.pow(mouse.x - dragStartPos.x, 2) + Math.pow(mouse.y - dragStartPos.y, 2))
                                   if (distance > 5) {
                                       dragging = true
                                       targetIndex = index
                                       originalIndex = index
                                   }
                               }
                               if (dragging) {
                                   dragOffset = Qt.point(mouse.x - dragStartPos.x, mouse.y - dragStartPos.y)
                                   if (dockApps) {
                                       const threshold = 40
                                       let newTargetIndex = targetIndex
                                       if (dragOffset.x > threshold && targetIndex < dockApps.pinnedAppCount - 1) {
                                           newTargetIndex = targetIndex + 1
                                       } else if (dragOffset.x < -threshold && targetIndex > 0) {
                                           newTargetIndex = targetIndex - 1
                                       }
                                       if (newTargetIndex !== targetIndex) {
                                           targetIndex = newTargetIndex
                                           dragStartPos = Qt.point(mouse.x, mouse.y)
                                       }
                                   }
                               }
                           }
        onClicked: mouse => {
                       if (!appData || longPressing) {
                           return
                       }

                       if (mouse.button === Qt.LeftButton) {
                           if (appData.type === "pinned") {
                               if (appData && appData.appId) {
                                   const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
                                   if (desktopEntry) {
                                       AppUsageHistoryData.addAppUsage({
                                                                           "id": appData.appId,
                                                                           "name": desktopEntry.name || appData.appId,
                                                                           "icon": desktopEntry.icon || "",
                                                                           "exec": desktopEntry.exec || "",
                                                                           "comment": desktopEntry.comment || ""
                                                                       })
                                   }
                                   SessionService.launchDesktopEntry(desktopEntry)
                               }
                           } else if (appData.type === "window") {
                               const toplevel = getToplevelObject()
                               if (toplevel) {
                                   toplevel.activate()
                               }
                           } else if (appData.type === "grouped") {
                               if (appData.windowCount === 0) {
                                   if (appData && appData.appId) {
                                       const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
                                       if (desktopEntry) {
                                           AppUsageHistoryData.addAppUsage({
                                                                               "id": appData.appId,
                                                                               "name": desktopEntry.name || appData.appId,
                                                                               "icon": desktopEntry.icon || "",
                                                                               "exec": desktopEntry.exec || "",
                                                                               "comment": desktopEntry.comment || ""
                                                                           })
                                       }
                                       SessionService.launchDesktopEntry(desktopEntry)
                                   }
                               } else if (appData.windowCount === 1) {
                                   // For single window, activate directly
                                   const toplevel = getToplevelObject()
                                   if (toplevel) {
                                       console.log("Activating grouped app window:", appData.windowTitle)
                                       toplevel.activate()
                                   } else {
                                       console.warn("No toplevel found for grouped app")
                                   }
                               } else {
                                   // For multiple windows, show context menu (hide pin option for left-click)
                                   if (contextMenu) {
                                       contextMenu.showForButton(root, appData, 65, true)
                                   }
                               }
                           }
                       } else if (mouse.button === Qt.MiddleButton) {
                           if (appData && appData.appId) {
                               const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
                               if (desktopEntry) {
                                   AppUsageHistoryData.addAppUsage({
                                                                       "id": appData.appId,
                                                                       "name": desktopEntry.name || appData.appId,
                                                                       "icon": desktopEntry.icon || "",
                                                                       "exec": desktopEntry.exec || "",
                                                                       "comment": desktopEntry.comment || ""
                                                                   })
                               }
                             SessionService.launchDesktopEntry(desktopEntry)
                           }
                       } else if (mouse.button === Qt.RightButton) {
                           if (contextMenu && appData) {
                               console.log("Right-clicked on app:", appData.appId, "type:", appData.type, "windowCount:", appData.windowCount || 0)
                               contextMenu.showForButton(root, appData, 40, false)
                           } else {
                               console.warn("No context menu or appData available")
                           }
                       }
                   }
    }

    IconImage {
        id: iconImg

        anchors.centerIn: parent
        implicitSize: 40
        source: {
            if (appData.appId === "__SEPARATOR__") {
                return ""
            }
            const moddedId = Paths.moddedAppId(appData.appId)
            if (moddedId.toLowerCase().includes("steam_app")) {
                return ""
            }
            const desktopEntry = DesktopEntries.heuristicLookup(moddedId)
            return desktopEntry && desktopEntry.icon ? Quickshell.iconPath(desktopEntry.icon, true) : ""
        }
        mipmap: true
        smooth: true
        asynchronous: true
        visible: status === Image.Ready
    }

    DankIcon {
        anchors.centerIn: parent
        size: 40
        name: "sports_esports"
        color: Theme.surfaceText
        visible: {
            if (!appData || !appData.appId || appData.appId === "__SEPARATOR__") {
                return false
            }
            const moddedId = Paths.moddedAppId(appData.appId)
            return moddedId.toLowerCase().includes("steam_app")
        }
    }

    Rectangle {
        width: 40
        height: 40
        anchors.centerIn: parent
        visible: iconImg.status !== Image.Ready
        color: Theme.surfaceLight
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.primarySelected

        Text {
            anchors.centerIn: parent
            text: {
                if (!appData || !appData.appId) {
                    return "?"
                }

                const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
                if (desktopEntry && desktopEntry.name) {
                    return desktopEntry.name.charAt(0).toUpperCase()
                }

                return appData.appId.charAt(0).toUpperCase()
            }
            font.pixelSize: 14
            color: Theme.primary
            font.weight: Font.Bold
        }
    }

    // Indicator for running/focused state
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -2
        spacing: 2
        visible: appData && (appData.isRunning || appData.type === "window" || (appData.type === "grouped" && appData.windowCount > 0))

        Repeater {
            model: {
                if (!appData) return 0
                if (appData.type === "grouped") {
                    return Math.min(appData.windowCount, 4)
                } else if (appData.type === "window" || appData.isRunning) {
                    return 1
                }
                return 0
            }

            Rectangle {
                width: appData && appData.type === "grouped" && appData.windowCount > 1 ? 4 : 8
                height: 2
                radius: 1
                color: {
                    if (!appData) {
                        return "transparent"
                    }

                    if (appData.type !== "grouped" || appData.windowCount === 1) {
                        if (isWindowFocused) {
                            return Theme.primary
                        }
                        return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                    }

                    if (appData.type === "grouped" && appData.windowCount > 1) {
                        const groupToplevels = getGroupedToplevels()
                        if (index < groupToplevels.length && groupToplevels[index].activated) {
                            return Theme.primary
                        }
                    }

                    return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                }
            }
        }
    }


    transform: Translate {
        id: translateY

        y: 0
    }
}
