import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets

ApplicationWindow {
    visible: true
    width: 860
    height: 640
    color: "transparent"//"#2e271e"

    property string currentTab: "Apps"
    property string searchText: ""
    property string selectedWallpaper: ""
    property int selectedAppIndex: -1
    property bool lightTheme: false
    property var sortedApps: []
    readonly property string normalizedSearch: searchText.trim().toLowerCase()

    function appMatches(entry) {
        if (!entry) {
            return false
        }

        if (normalizedSearch === "") {
            return !entry.noDisplay
        }

        var haystack = [
            entry.name || "",
            entry.genericName || "",
            entry.comment || "",
            entry.id || ""
        ]

        if (entry.keywords) {
            haystack = haystack.concat(entry.keywords)
        }

        return !entry.noDisplay
            && haystack.join(" ").toLowerCase().indexOf(normalizedSearch) !== -1
    }

    function iconSource(iconName) {
        if (!iconName || iconName === "") {
            return "image://icon/application-x-executable"
        }

        return "image://icon/" + iconName
    }

    function focusSearch() {
        searchField.forceActiveFocus()
        searchField.selectAll()
    }

    function rebuildSortedApps() {
        var entries = DesktopEntries.applications.values || []
        var nextApps = entries.slice()

        nextApps.sort(function(a, b) {
            var left = (a && (a.name || a.id) || "").toLowerCase()
            var right = (b && (b.name || b.id) || "").toLowerCase()

            if (left < right) {
                return -1
            }

            if (left > right) {
                return 1
            }

            return 0
        })

        sortedApps = nextApps
    }

    function firstMatchedAppIndex() {
        var entries = sortedApps

        for (var i = 0; i < entries.length; ++i) {
            if (appMatches(entries[i])) {
                return i
            }
        }

        return -1
    }

    function stepMatchedAppIndex(step) {
        var entries = sortedApps

        if (!entries || entries.length === 0) {
            return -1
        }

        var index = selectedAppIndex

        if (index < 0 || index >= entries.length || !appMatches(entries[index])) {
            index = firstMatchedAppIndex()
        }

        if (index < 0) {
            return -1
        }

        for (var i = index + step; i >= 0 && i < entries.length; i += step) {
            if (appMatches(entries[i])) {
                return i
            }
        }

        return index
    }

    function syncSelectedApp() {
        selectedAppIndex = firstMatchedAppIndex()

        if (currentTab === "Apps" && contentLoader.item && selectedAppIndex >= 0) {
            contentLoader.item.positionViewAtIndex(selectedAppIndex, ListView.Contain)
        }
    }

    function moveSelectedApp(step) {
        var nextIndex = stepMatchedAppIndex(step)

        if (nextIndex < 0) {
            return
        }

        selectedAppIndex = nextIndex

        if (currentTab === "Apps" && contentLoader.item) {
            contentLoader.item.positionViewAtIndex(selectedAppIndex, ListView.Contain)
        }
    }

    function activateSelectedApp() {
        var entries = sortedApps

        if (!entries || selectedAppIndex < 0 || selectedAppIndex >= entries.length) {
            return
        }

        var entry = entries[selectedAppIndex]

        if (!appMatches(entry)) {
            return
        }

        entry.execute()
        Qt.quit()
    }

    Connections {
        target: DesktopEntries.applications

        function onValuesChanged() {
            rebuildSortedApps()
            syncSelectedApp()
        }
    }

    FolderListModel {
        id: wallpapersModel
        folder: "file:///home/shingetsu/Pictures/wallpapers"
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    Rectangle {
        anchors.fill: parent
        radius: 26
        color: "#11131acc"
        border.width: 1
        border.color: "#2d3340"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 260
                Layout.preferredHeight: 52
                radius: 18
                color: "#1a1e26"

                property int tabWidth: 120
                property int tabHeight: 40
                property int tabSpacing: 8
                property int sidePadding: 6

                Rectangle {
                    id: activeTabBg
                    y: 6
                    width: parent.tabWidth
                    height: parent.tabHeight
                    radius: 14
                    color: "#3c2a2a"
                    border.width: 1
                    border.color: "#8d5a5a"

                    x: currentTab === "Apps"
                    ? parent.sidePadding
                    : parent.sidePadding + parent.tabWidth + parent.tabSpacing

                    Behavior on x {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.InOutCubic
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: parent.tabSpacing

                    Rectangle {
                        width: parent.parent.tabWidth
                        height: parent.parent.tabHeight
                        radius: 14
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Apps"
                            color: currentTab === "Apps" ? "#f1f5fb" : "#97a0af"
                            font.pixelSize: 16
                            font.weight: Font.Medium

                            Behavior on color {
                                ColorAnimation { duration: 180 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentTab = "Apps"
                        }
                    }

                    Rectangle {
                        width: parent.parent.tabWidth
                        height: parent.parent.tabHeight
                        radius: 14
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Walls"
                            color: currentTab === "Walls" ? "#ffaaaa" : "#97a0af"
                            font.pixelSize: 16
                            font.weight: Font.Medium

                            Behavior on color {
                                ColorAnimation { duration: 180 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentTab = "Walls"
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: 86
                Layout.preferredHeight: 52
                Layout.alignment: Qt.AlignRight
                radius: 18
                color: "#1a1e26"

                Rectangle {
                    anchors.centerIn: parent
                    width: 70
                    height: 34
                    radius: 17
                    color: lightTheme ? "#f3f5f8" : "#0f1218"
                    border.width: 1
                    border.color: lightTheme ? "#d8dee8" : "#353b47"

                    Behavior on color {
                        ColorAnimation { duration: 220 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 220 }
                    }

                    Rectangle {
                        id: themeKnob
                        y: 2
                        width: 30
                        height: 30
                        radius: 15
                        color: lightTheme ? "#ffffff" : "#232833"
                        border.width: 1
                        border.color: lightTheme ? "#e7ebf3" : "#404857"

                        x: lightTheme ? parent.width - width - 2 : 2

                        Behavior on x {
                            NumberAnimation {
                                duration: 240
                                easing.type: Easing.InOutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 220 }
                        }

                        Behavior on border.color {
                            ColorAnimation { duration: 220 }
                        }

                        scale: themeSwitchArea.pressed ? 0.92 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: themeSwitchArea
                        anchors.fill: parent
                        onClicked: lightTheme = !lightTheme
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            radius: 16
            color: "#0f1218"
            border.width: 1
            border.color: "#353b47"

            TextField {
                id: searchField
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                color: "#e7ebf3"
                placeholderText: currentTab === "Walls" ? "Search wallpapers..." : "Search apps..."
                placeholderTextColor: "#788190"
                font.pixelSize: 17
                background: null
                selectByMouse: true
                focus: currentTab === "Apps"

                onTextChanged: {
                    searchText = text
                    syncSelectedApp()
                }

                Keys.onPressed: event => {
                    if (currentTab !== "Apps") {
                        return
                    }

                    if (event.key === Qt.Key_Down) {
                        moveSelectedApp(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        moveSelectedApp(-1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        activateSelectedApp()
                        event.accepted = true
                    }
                }
            }
        }

        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: currentTab === "Walls" ? wallsComponent : appsComponent

            onLoaded: {
                if (currentTab === "Apps") {
                    syncSelectedApp()
                    focusSearch()
                }
            }
        }
    }

    onCurrentTabChanged: {
        if (currentTab === "Apps") {
            syncSelectedApp()
            focusSearch()
        }
    }

    Component.onCompleted: {
        rebuildSortedApps()
        syncSelectedApp()
        focusSearch()
    }

    Component {
        id: appsComponent

        ListView {
            id: appsList
            anchors.fill: parent
            clip: true
            spacing: 10
            boundsBehavior: Flickable.StopAtBounds
            model: sortedApps

            delegate: Rectangle {
                required property var modelData
                required property int index

                property var entry: modelData
                property bool matched: appMatches(entry)
                property bool selected: matched && index === selectedAppIndex

                width: appsList.width
                height: matched ? 68 : 0
                radius: 18
                color: selected ? "#211817" : (hovered ? "#171c24" : "#10141b")
                border.width: matched ? 1 : 0
                border.color: selected ? "#d28a8a" : (hovered ? "#8d5a5a" : "#2d3440")
                visible: height > 0
                opacity: matched ? 1 : 0

                Behavior on height {
                    NumberAnimation {
                        duration: 140
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }

                property bool hovered: false

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 12
                    anchors.bottomMargin: 12
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        radius: 12
                        color: "#1c222c"
                        border.width: 1
                        border.color: "#303846"

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 24
                            width: 24
                            height: 24
                            source: iconSource(entry.icon)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: entry.name || entry.id || "Unknown app"
                            color: selected ? "#fff1f1" : "#e7ebf3"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: entry.genericName || entry.comment || entry.id || ""
                            color: selected ? "#d8b2b2" : "#8f98a8"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: {
                        selectedAppIndex = index
                        activateSelectedApp()
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }

    Component {
        id: wallsComponent

        GridView {
            id: wallsGrid
            anchors.fill: parent
            cellWidth: 180
            cellHeight: 150
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            model: wallpapersModel

            delegate: Item {
                width: wallsGrid.cellWidth
                height: wallsGrid.cellHeight

                property string wallUrl: fileUrl
                property string wallPath: fileUrl.toString().replace("file://", "")
                property string wallName: fileName
                property bool matched: searchText === ""
                                       || wallName.toLowerCase().indexOf(searchText.toLowerCase()) !== -1

                visible: matched

                Rectangle {
                    id: card
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 8
                    height: 132
                    radius: 18
                    color: hovered ? "#1a1f27" : "#10141b"
                    border.width: selectedWallpaper === wallPath ? 2 : 1
                    border.color: selectedWallpaper === wallPath ? "#d28a8a" : "#2d3440"

                    property bool hovered: false

                    scale: hovered ? 1.03 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 10
                        height: 90
                        radius: 12
                        clip: true
                        color: "#0b0d12"

                        Image {
                            anchors.fill: parent
                            source: wallUrl
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.bottomMargin: 10
                        text: wallName
                        color: selectedWallpaper === wallPath ? "#efb1b1" : "#d8dde7"
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: card.hovered = true
                        onExited: card.hovered = false

                        onClicked: {
                            selectedWallpaper = wallPath
                            console.log("Set wallpaper:", wallPath)

                            Quickshell.execDetached([
                                "bash",
                                "-lc",
                                "wall=\"$1\"; " +
                                "conf=\"$HOME/.config/hypr/hyprpaper.conf\"; " +

                                "hyprctl hyprpaper preload \"$wall\"; " +
                                "hyprctl monitors -j | jq -r '.[].description' | while read -r mon; do " +
                                "hyprctl hyprpaper wallpaper \"desc:$mon,$wall\"; " +
                                "done; " +

                                "escaped=$(printf '%s\n' \"$wall\" | sed 's/[&/\\\\]/\\\\&/g'); " +
                                "sed -i \"s|^\\([[:space:]]*path[[:space:]]*=[[:space:]]*\\).*|\\1$escaped|\" \"$conf\"",
                                "_",
                                wallPath
                            ])
                        }
                    }
                }
            }
        }
    }
}
