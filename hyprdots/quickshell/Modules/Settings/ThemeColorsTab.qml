import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modals
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: themeColorsTab

    property var cachedFontFamilies: []
    property var cachedMonoFamilies: []
    property bool fontsEnumerated: false

    function enumerateFonts() {
        var fonts = ["Default"]
        var availableFonts = Qt.fontFamilies()
        var rootFamilies = []
        var seenFamilies = new Set()
        for (var i = 0; i < availableFonts.length; i++) {
            var fontName = availableFonts[i]
            if (fontName.startsWith("."))
                continue

            if (fontName === SettingsData.defaultFontFamily)
                continue

            var rootName = fontName.replace(
                        / (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i,
                        "").replace(
                        / (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i,
                        "").replace(/ (UI|Display|Text|Mono|Sans|Serif)$/i,
                                    function (match, suffix) {
                                        return match
                                    }).trim()
            if (!seenFamilies.has(rootName) && rootName !== "") {
                seenFamilies.add(rootName)
                rootFamilies.push(rootName)
            }
        }
        cachedFontFamilies = fonts.concat(rootFamilies.sort())
        var monoFonts = ["Default"]
        var monoFamilies = []
        var seenMonoFamilies = new Set()
        for (var j = 0; j < availableFonts.length; j++) {
            var fontName2 = availableFonts[j]
            if (fontName2.startsWith("."))
                continue

            if (fontName2 === SettingsData.defaultMonoFontFamily)
                continue

            var lowerName = fontName2.toLowerCase()
            if (lowerName.includes("mono") || lowerName.includes(
                        "code") || lowerName.includes(
                        "console") || lowerName.includes(
                        "terminal") || lowerName.includes(
                        "courier") || lowerName.includes(
                        "dejavu sans mono") || lowerName.includes(
                        "jetbrains") || lowerName.includes(
                        "fira") || lowerName.includes(
                        "hack") || lowerName.includes(
                        "source code") || lowerName.includes(
                        "ubuntu mono") || lowerName.includes("cascadia")) {
                var rootName2 = fontName2.replace(
                            / (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i,
                            "").replace(
                            / (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i,
                            "").trim()
                if (!seenMonoFamilies.has(rootName2) && rootName2 !== "") {
                    seenMonoFamilies.add(rootName2)
                    monoFamilies.push(rootName2)
                }
            }
        }
        cachedMonoFamilies = monoFonts.concat(monoFamilies.sort())
    }

    Component.onCompleted: {
        if (!fontsEnumerated) {
            enumerateFonts()
            fontsEnumerated = true
        }
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL


            // Theme Color
            StyledRect {
                width: parent.width
                height: themeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: themeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "palette"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Theme Color"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: parent.width - parent.children[0].width - parent.children[1].width - surfaceBaseGroup.width - Theme.spacingM * 3
                            height: 1
                        }

                        DankButtonGroup {
                            id: surfaceBaseGroup
                            property int currentSurfaceIndex: {
                                switch (SettingsData.surfaceBase) {
                                    case "sc": return 0
                                    case "s": return 1
                                    default: return 0
                                }
                            }

                            model: ["Container", "Surface"]
                            currentIndex: currentSurfaceIndex
                            selectionMode: "single"
                            anchors.verticalCenter: parent.verticalCenter

                            buttonHeight: 20
                            minButtonWidth: 48
                            buttonPadding: Theme.spacingS
                            checkIconSize: Theme.iconSizeSmall - 2
                            textSize: Theme.fontSizeSmall - 2
                            spacing: 1

                            onSelectionChanged: (index, selected) => {
                                if (!selected) return
                                const surfaceOptions = ["sc", "s"]
                                SettingsData.setSurfaceBase(surfaceOptions[index])
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: {
                                if (Theme.currentTheme === Theme.dynamic) {
                                    return "Current Theme: Dynamic"
                                } else if (Theme.currentThemeCategory === "catppuccin") {
                                    return "Current Theme: Catppuccin " + Theme.getThemeColors(Theme.currentThemeName).name
                                } else {
                                    return "Current Theme: " + Theme.getThemeColors(Theme.currentThemeName).name
                                }
                            }
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: {
                                if (Theme.currentTheme === Theme.dynamic) {
                                    return "Material colors generated from wallpaper"
                                }
                                if (Theme.currentThemeCategory === "catppuccin") {
                                    return "Soothing pastel theme based on Catppuccin"
                                }
                                if (Theme.currentTheme === Theme.custom) {
                                    return "Custom theme loaded from JSON file"
                                }
                                return "Material Design inspired color themes"
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.horizontalCenter: parent.horizontalCenter
                            wrapMode: Text.WordWrap
                            width: Math.min(parent.width, 400)
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }


                    Column {
                        spacing: Theme.spacingM
                        anchors.horizontalCenter: parent.horizontalCenter

                        DankButtonGroup {
                            property int currentThemeIndex: {
                                if (Theme.currentTheme === Theme.dynamic) return 2
                                if (Theme.currentThemeName === "custom") return 3
                                if (Theme.currentThemeCategory === "catppuccin") return 1
                                return 0
                            }

                            model: ["Generic", "Catppuccin", "Auto", "Custom"]
                            currentIndex: currentThemeIndex
                            selectionMode: "single"
                            anchors.horizontalCenter: parent.horizontalCenter
                            onSelectionChanged: (index, selected) => {
                                if (!selected) return
                                switch (index) {
                                    case 0: Theme.switchThemeCategory("generic", "blue"); break
                                    case 1: Theme.switchThemeCategory("catppuccin", "cat-mauve"); break
                                    case 2:
                                        if (ToastService.wallpaperErrorStatus === "matugen_missing")
                                            ToastService.showError("matugen not found - install matugen package for dynamic theming")
                                        else if (ToastService.wallpaperErrorStatus === "error")
                                            ToastService.showError("Wallpaper processing failed - check wallpaper path")
                                        else
                                            Theme.switchTheme(Theme.dynamic, true, false)
                                        break
                                    case 3:
                                        if (Theme.currentThemeName !== "custom") {
                                            Theme.switchTheme("custom", true, false)
                                        }
                                        break
                                }
                            }
                        }

                        Column {
                            spacing: Theme.spacingS
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: Theme.currentThemeCategory === "generic" && Theme.currentTheme !== Theme.dynamic && Theme.currentThemeName !== "custom"

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["blue", "purple", "green", "orange", "red"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getThemeColors(themeName).primary
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameText.contentWidth + Theme.spacingS * 2
                                            height: nameText.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseArea.containsMouse

                                            StyledText {
                                                id: nameText
                                                text: Theme.getThemeColors(themeName).name
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cyan", "pink", "amber", "coral", "monochrome"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getThemeColors(themeName).primary
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameText2.contentWidth + Theme.spacingS * 2
                                            height: nameText2.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseArea2.containsMouse

                                            StyledText {
                                                id: nameText2
                                                text: Theme.getThemeColors(themeName).name
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            spacing: Theme.spacingS
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: Theme.currentThemeCategory === "catppuccin" && Theme.currentTheme !== Theme.dynamic && Theme.currentThemeName !== "custom"

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cat-rosewater", "cat-flamingo", "cat-pink", "cat-mauve", "cat-red", "cat-maroon", "cat-peach"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getCatppuccinColor(themeName)
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameTextCat.contentWidth + Theme.spacingS * 2
                                            height: nameTextCat.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseAreaCat.containsMouse

                                            StyledText {
                                                id: nameTextCat
                                                text: Theme.getCatppuccinVariantName(themeName)
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseAreaCat
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cat-yellow", "cat-green", "cat-teal", "cat-sky", "cat-sapphire", "cat-blue", "cat-lavender"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getCatppuccinColor(themeName)
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameTextCat2.contentWidth + Theme.spacingS * 2
                                            height: nameTextCat2.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseAreaCat2.containsMouse

                                            StyledText {
                                                id: nameTextCat2
                                                text: Theme.getCatppuccinVariantName(themeName)
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseAreaCat2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: Theme.currentTheme === Theme.dynamic

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledRect {
                                    width: 120
                                    height: 90
                                    radius: Theme.cornerRadius
                                    color: Theme.surfaceVariant
                                    border.color: Theme.outline
                                    border.width: 0

                                    CachingImage {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: Theme.wallpaperPath ? "file://" + Theme.wallpaperPath : ""
                                        fillMode: Image.PreserveAspectCrop
                                        visible: Theme.wallpaperPath && !Theme.wallpaperPath.startsWith("#")
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            maskEnabled: true
                                            maskSource: autoWallpaperMask
                                            maskThresholdMin: 0.5
                                            maskSpreadAtMin: 1
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        radius: Theme.cornerRadius - 1
                                        color: Theme.wallpaperPath && Theme.wallpaperPath.startsWith("#") ? Theme.wallpaperPath : "transparent"
                                        visible: Theme.wallpaperPath && Theme.wallpaperPath.startsWith("#")
                                    }

                                    Rectangle {
                                        id: autoWallpaperMask
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        radius: Theme.cornerRadius - 1
                                        color: "black"
                                        visible: false
                                        layer.enabled: true
                                    }

                                    DankIcon {
                                        anchors.centerIn: parent
                                        name: {
                                            if (ToastService.wallpaperErrorStatus === "error" || ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return "error"
                                            else
                                                return "palette"
                                        }
                                        size: Theme.iconSizeLarge
                                        color: {
                                            if (ToastService.wallpaperErrorStatus === "error" || ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return Theme.error
                                            else
                                                return Theme.surfaceVariantText
                                        }
                                        visible: !Theme.wallpaperPath
                                    }
                                }

                                Column {
                                    width: parent.width - 120 - Theme.spacingM
                                    spacing: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: {
                                            if (ToastService.wallpaperErrorStatus === "error")
                                                return "Wallpaper Error"
                                            else if (ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return "Matugen Missing"
                                            else if (Theme.wallpaperPath)
                                                return Theme.wallpaperPath.split('/').pop()
                                            else
                                                return "No wallpaper selected"
                                        }
                                        font.pixelSize: Theme.fontSizeLarge
                                        color: Theme.surfaceText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: {
                                            if (ToastService.wallpaperErrorStatus === "error")
                                                return "Wallpaper processing failed"
                                            else if (ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return "Install matugen package for dynamic theming"
                                            else if (Theme.wallpaperPath)
                                                return Theme.wallpaperPath
                                            else
                                                return "Dynamic colors from wallpaper"
                                        }
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: {
                                            if (ToastService.wallpaperErrorStatus === "error" || ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return Theme.error
                                            else
                                                return Theme.surfaceVariantText
                                        }
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 2
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            DankDropdown {
                                id: matugenPaletteDropdown
                                width: parent.width
                                text: "Matugen Palette"
                                description: "Select the palette algorithm used for wallpaper-based colors"
                                options: Theme.availableMatugenSchemes.map(function (option) { return option.label })
                                currentValue: Theme.getMatugenScheme(SettingsData.matugenScheme).label
                                enabled: Theme.matugenAvailable
                                opacity: enabled ? 1 : 0.4
                                onValueChanged: value => {
                                    for (var i = 0; i < Theme.availableMatugenSchemes.length; i++) {
                                        var option = Theme.availableMatugenSchemes[i]
                                        if (option.label === value) {
                                            SettingsData.setMatugenScheme(option.value)
                                            break
                                        }
                                    }
                                }
                            }

                            StyledText {
                                text: {
                                    var scheme = Theme.getMatugenScheme(SettingsData.matugenScheme)
                                    return scheme.description + " (" + scheme.value + ")"
                                }
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: Theme.currentThemeName === "custom"

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DankActionButton {
                                    buttonSize: 48
                                    iconName: "folder_open"
                                    iconSize: Theme.iconSize
                                    backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                                    iconColor: Theme.primary
                                    onClicked: fileBrowserModal.open()
                                }

                                Column {
                                    width: parent.width - 48 - Theme.spacingM
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: SettingsData.customThemeFile ? SettingsData.customThemeFile.split('/').pop() : "No custom theme file"
                                        font.pixelSize: Theme.fontSizeLarge
                                        color: Theme.surfaceText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: SettingsData.customThemeFile || "Click to select a custom theme JSON file"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Transparency Settings
            StyledRect {
                width: parent.width
                height: transparencySection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: transparencySection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "opacity"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Widget Styling"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Top Bar Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.topBarTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setTopBarTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Item {
                            width: parent.width
                            height: Math.max(transparencyLabel.height, widgetColorGroup.height)

                            StyledText {
                                id: transparencyLabel
                                text: "Top Bar Widget Transparency"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DankButtonGroup {
                                id: widgetColorGroup
                                property int currentColorIndex: {
                                    switch (SettingsData.widgetBackgroundColor) {
                                        case "sth": return 0
                                        case "s": return 1
                                        case "sc": return 2
                                        case "sch": return 3
                                        default: return 0
                                    }
                                }

                                model: ["sth", "s", "sc", "sch"]
                                currentIndex: currentColorIndex
                                selectionMode: "single"
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                buttonHeight: 20
                                minButtonWidth: 32
                                buttonPadding: Theme.spacingS
                                checkIconSize: Theme.iconSizeSmall - 2
                                textSize: Theme.fontSizeSmall - 2
                                spacing: 1

                                onSelectionChanged: (index, selected) => {
                                    if (!selected) return
                                    const colorOptions = ["sth", "s", "sc", "sch"]
                                    SettingsData.setWidgetBackgroundColor(colorOptions[index])
                                }
                            }
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.topBarWidgetTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setTopBarWidgetTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Popup Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.popupTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setPopupTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }


                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Corner Radius (0 = square corners)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.cornerRadius
                            minimum: 0
                            maximum: 32
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setCornerRadius(
                                                          newValue)
                                                  }
                        }
                    }
                }
            }

            // System Configuration Warning
            Rectangle {
                width: parent.width
                height: warningText.implicitHeight + Theme.spacingM * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.warning.r, Theme.warning.g,
                               Theme.warning.b, 0.12)
                border.color: Qt.rgba(Theme.warning.r, Theme.warning.g,
                                      Theme.warning.b, 0.3)
                border.width: 0

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "info"
                        size: Theme.iconSizeSmall
                        color: Theme.warning
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        id: warningText
                        font.pixelSize: Theme.fontSizeSmall
                        text: "The below settings will modify your GTK and Qt settings. If you wish to preserve your current configurations, please back them up (qt5ct.conf|qt6ct.conf and ~/.config/gtk-3.0|gtk-4.0)."
                        wrapMode: Text.WordWrap
                        width: parent.width - Theme.iconSizeSmall - Theme.spacingM
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Icon Theme
            StyledRect {
                width: parent.width
                height: iconThemeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: iconThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        DankIcon {
                            name: "image"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DankDropdown {
                            width: parent.width - Theme.iconSize - Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Icon Theme"
                            description: "DankShell & System Icons\n(requires restart)"
                            currentValue: SettingsData.iconTheme
                            enableFuzzySearch: true
                            popupWidthOffset: 100
                            maxPopupHeight: 236
                            options: {
                                SettingsData.detectAvailableIconThemes()
                                return SettingsData.availableIconThemes
                            }
                            onValueChanged: value => {
                                                SettingsData.setIconTheme(value)
                                                if (Quickshell.env("QT_QPA_PLATFORMTHEME") != "gtk3" &&
                                                    Quickshell.env("QT_QPA_PLATFORMTHEME") != "qt6ct" &&
                                                    Quickshell.env("QT_QPA_PLATFORMTHEME_QT6") != "qt6ct") {
                                                    ToastService.showError("Missing Environment Variables", "You need to set either:\nQT_QPA_PLATFORMTHEME=gtk3 OR\nQT_QPA_PLATFORMTHEME=qt6ct\nas environment variables, and then restart the shell.\n\nqt6ct requires qt6ct-kde to be installed.")
                                                }
                                            }
                        }
                    }
                }
            }

            // System App Theming
            StyledRect {
                width: parent.width
                height: systemThemingSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0
                visible: Theme.matugenAvailable

                Column {
                    id: systemThemingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "extension"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "System App Theming"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Rectangle {
                            width: (parent.width - Theme.spacingM) / 2
                            height: 48
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                            border.color: Theme.primary
                            border.width: 0

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                DankIcon {
                                    name: "folder"
                                    size: 16
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Apply GTK Colors"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.primary
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.applyGtkColors()
                            }
                        }

                        Rectangle {
                            width: (parent.width - Theme.spacingM) / 2
                            height: 48
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                            border.color: Theme.primary
                            border.width: 0

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                DankIcon {
                                    name: "settings"
                                    size: 16
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Apply Qt Colors"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.primary
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.applyQtColors()
                            }
                        }
                    }

                    StyledText {
                        text: `Generate baseline GTK3/4 or QT5/QT6 (requires qt6ct-kde) configurations to follow DMS colors. Only needed once.<br /><br />It is recommended to install <a href="https://github.com/AvengeMedia/DankMaterialShell/blob/master/README.md#Theming" style="text-decoration:none; color:${Theme.primary};">Colloid</a> GTK theme prior to applying GTK themes.`
                        textFormat: Text.RichText
                        linkColor: Theme.primary
                        onLinkActivated: url => Qt.openUrlExternally(url)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                            acceptedButtons: Qt.NoButton
                            propagateComposedEvents: true
                        }
                    }
                }
            }
        }
    }

    FileBrowserModal {
        id: fileBrowserModal
        browserTitle: "Select Custom Theme"
        filterExtensions: ["*.json"]
        showHiddenFiles: true

        function selectCustomTheme() {
            shouldBeVisible = true
        }

        onFileSelected: function(filePath) {
            // Save the custom theme file path and switch to custom theme
            if (filePath.endsWith(".json")) {
                SettingsData.setCustomThemeFile(filePath)
                Theme.switchTheme("custom")
                close()
            }
        }
    }
}
