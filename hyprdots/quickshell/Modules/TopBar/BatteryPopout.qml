import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

DankPopout {
    id: root

    property string triggerSection: "right"
    property var triggerScreen: null

    function setTriggerPosition(x, y, width, section, screen) {
        triggerX = x;
        triggerY = y;
        triggerWidth = width;
        triggerSection = section;
        triggerScreen = screen;
    }

    function isActiveProfile(profile) {
        if (typeof PowerProfiles === "undefined") {
            return false;
        }

        return PowerProfiles.profile === profile;
    }

    function setProfile(profile) {
        if (typeof PowerProfiles === "undefined") {
            ToastService.showError("power-profiles-daemon not available");
            return ;
        }
        PowerProfiles.profile = profile;
        if (PowerProfiles.profile !== profile) {
            ToastService.showError("Failed to set power profile");
        }

    }

    popupWidth: 400
    popupHeight: contentLoader.item ? contentLoader.item.implicitHeight : 400
    triggerX: Screen.width - 380 - Theme.spacingL
    triggerY: Theme.barHeight - 4 + SettingsData.topBarSpacing + Theme.popupDistance
    triggerWidth: 70
    positioning: "center"
    screen: triggerScreen
    shouldBeVisible: false
    visible: shouldBeVisible

    content: Component {
        Rectangle {
            id: batteryContent

            implicitHeight: contentColumn.implicitHeight + Theme.spacingL * 2
            color: Theme.popupBackground()
            radius: Theme.cornerRadius
            border.color: Theme.outlineMedium
            border.width: 0
            antialiasing: true
            smooth: true
            focus: true
            Component.onCompleted: {
                if (root.shouldBeVisible) {
                    forceActiveFocus();
                }

            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.close();
                    event.accepted = true;
                }
            }

            Connections {
                function onShouldBeVisibleChanged() {
                    if (root.shouldBeVisible) {
                        Qt.callLater(function() {
                            batteryContent.forceActiveFocus();
                        });
                    }

                }

                target: root
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                color: "transparent"
                radius: parent.radius + 3
                border.color: Qt.rgba(0, 0, 0, 0.05)
                border.width: 0
                z: -3
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                color: "transparent"
                radius: parent.radius + 2
                border.color: Theme.shadowMedium
                border.width: 0
                z: -2
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Theme.outlineStrong
                border.width: 0
                radius: parent.radius
                z: -1
            }

            Column {
                id: contentColumn

                width: parent.width - Theme.spacingL * 2
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingL

                Row {
                    width: parent.width
                    height: 48
                    spacing: Theme.spacingM

                    DankIcon {
                        name: {
                            if (!BatteryService.batteryAvailable)
                                return "power";

                            if (!BatteryService.isCharging && BatteryService.isPluggedIn) {
                                if (BatteryService.batteryLevel >= 90) {
                                    return "battery_charging_full";
                                }
                                if (BatteryService.batteryLevel >= 80) {
                                    return "battery_charging_90";
                                }
                                if (BatteryService.batteryLevel >= 60) {
                                    return "battery_charging_80";
                                }
                                if (BatteryService.batteryLevel >= 50) {
                                    return "battery_charging_60";
                                }
                                if (BatteryService.batteryLevel >= 30) {
                                    return "battery_charging_50";
                                }
                                if (BatteryService.batteryLevel >= 20) {
                                    return "battery_charging_30";
                                }
                                return "battery_charging_20";
                            }
                            if (BatteryService.isCharging) {
                                if (BatteryService.batteryLevel >= 90) {
                                    return "battery_charging_full";
                                }
                                if (BatteryService.batteryLevel >= 80) {
                                    return "battery_charging_90";
                                }
                                if (BatteryService.batteryLevel >= 60) {
                                    return "battery_charging_80";
                                }
                                if (BatteryService.batteryLevel >= 50) {
                                    return "battery_charging_60";
                                }
                                if (BatteryService.batteryLevel >= 30) {
                                    return "battery_charging_50";
                                }
                                if (BatteryService.batteryLevel >= 20) {
                                    return "battery_charging_30";
                                }
                                return "battery_charging_20";
                            } else {
                                if (BatteryService.batteryLevel >= 95) {
                                    return "battery_full";
                                }
                                if (BatteryService.batteryLevel >= 85) {
                                    return "battery_6_bar";
                                }
                                if (BatteryService.batteryLevel >= 70) {
                                    return "battery_5_bar";
                                }
                                if (BatteryService.batteryLevel >= 55) {
                                    return "battery_4_bar";
                                }
                                if (BatteryService.batteryLevel >= 40) {
                                    return "battery_3_bar";
                                }
                                if (BatteryService.batteryLevel >= 25) {
                                    return "battery_2_bar";
                                }
                                return "battery_1_bar";
                            }
                        }
                        size: Theme.iconSizeLarge
                        color: {
                            if (BatteryService.isLowBattery && !BatteryService.isCharging)
                                return Theme.error;
                            if (BatteryService.isCharging || BatteryService.isPluggedIn)
                                return Theme.primary;
                            return Theme.surfaceText;
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        spacing: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Theme.iconSizeLarge - 32 - Theme.spacingM * 2

                        Row {
                            spacing: Theme.spacingS

                            StyledText {
                                text: BatteryService.batteryAvailable ? `${BatteryService.batteryLevel}%` : "Power"
                                font.pixelSize: Theme.fontSizeXLarge
                                color: {
                                    if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                                        return Theme.error;
                                    }
                                    if (BatteryService.isCharging) {
                                        return Theme.primary;
                                    }
                                    return Theme.surfaceText;
                                }
                                font.weight: Font.Bold
                            }

                            StyledText {
                                text: BatteryService.batteryAvailable ? BatteryService.batteryStatus : "Management"
                                font.pixelSize: Theme.fontSizeLarge
                                color: {
                                    if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                                        return Theme.error;
                                    }
                                    if (BatteryService.isCharging) {
                                        return Theme.primary;
                                    }
                                    return Theme.surfaceText;
                                }
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        StyledText {
                            text: {
                                if (!BatteryService.batteryAvailable) return "Power profile management available"
                                const time = BatteryService.formatTimeRemaining();
                                if (time !== "Unknown") {
                                    return BatteryService.isCharging ? `Time until full: ${time}` : `Time remaining: ${time}`;
                                }
                                return "";
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                            visible: text.length > 0
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: closeBatteryArea.containsMouse ? Theme.errorHover : "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        DankIcon {
                            anchors.centerIn: parent
                            name: "close"
                            size: Theme.iconSize - 4
                            color: closeBatteryArea.containsMouse ? Theme.error : Theme.surfaceText
                        }

                        MouseArea {
                            id: closeBatteryArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: {
                                root.close();
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    visible: BatteryService.batteryAvailable

                    StyledRect {
                        width: (parent.width - Theme.spacingM) / 2
                        height: 64
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        border.width: 0

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Health"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.primary
                                font.weight: Font.Medium
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: BatteryService.batteryHealth
                                font.pixelSize: Theme.fontSizeLarge
                                color: {
                                    if (BatteryService.batteryHealth === "N/A") {
                                        return Theme.surfaceText;
                                    }
                                    const healthNum = parseInt(BatteryService.batteryHealth);
                                    return healthNum < 80 ? Theme.error : Theme.surfaceText;
                                }
                                font.weight: Font.Bold
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    StyledRect {
                        width: (parent.width - Theme.spacingM) / 2
                        height: 64
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        border.width: 0

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Capacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.primary
                                font.weight: Font.Medium
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: BatteryService.batteryCapacity > 0 ? `${BatteryService.batteryCapacity.toFixed(1)} Wh` : "Unknown"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Bold
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                DankButtonGroup {
                    property var profileModel: (typeof PowerProfiles !== "undefined") ? [PowerProfile.PowerSaver, PowerProfile.Balanced].concat(PowerProfiles.hasPerformanceProfile ? [PowerProfile.Performance] : []) : [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
                    property int currentProfileIndex: {
                        if (typeof PowerProfiles === "undefined") return 1
                        return profileModel.findIndex(profile => root.isActiveProfile(profile))
                    }

                    model: profileModel.map(profile => Theme.getPowerProfileLabel(profile))
                    currentIndex: currentProfileIndex
                    selectionMode: "single"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onSelectionChanged: (index, selected) => {
                        if (!selected) return
                        root.setProfile(profileModel[index])
                    }
                }

                StyledRect {
                    width: parent.width
                    height: degradationContent.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
                    border.color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.3)
                    border.width: 0
                    visible: (typeof PowerProfiles !== "undefined") && PowerProfiles.degradationReason !== PerformanceDegradationReason.None

                    Column {
                        id: degradationContent
                        width: parent.width - Theme.spacingL * 2
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            DankIcon {
                                name: "warning"
                                size: Theme.iconSize
                                color: Theme.error
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: Theme.spacingXS
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - Theme.iconSize - Theme.spacingM

                                StyledText {
                                    text: "Power Profile Degradation"
                                    font.pixelSize: Theme.fontSizeLarge
                                    color: Theme.error
                                    font.weight: Font.Medium
                                }

                                StyledText {
                                    text: (typeof PowerProfiles !== "undefined") ? PerformanceDegradationReason.toString(PowerProfiles.degradationReason) : ""
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.8)
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}