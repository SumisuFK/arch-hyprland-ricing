import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

ApplicationWindow {
    visible: true
    width: 800
    height: 500
    color: "#1e1e2e"

    property string currentTab: "Walls"
    property string searchText: ""

    GridView {
        anchors.fill: parent
        cellWidth: 150
        cellHeight: 100

        model: ListModel {
            ListElement { path: "/home/shingetsu/Pictures/wallpapers/artoria_pendragon.jpg" }
            ListElement { path: "/home/shingetsu/Pictures/wallpapers/b-003.jpg" }
        }

        delegate: MouseArea {
            width: 140
            height: 90

            Image {
                anchors.fill: parent
                source: path
                fillMode: Image.PreserveAspectCrop
            }

            onClicked: {
                console.log("Set wallpaper:", path)

                Quickshell.execDetached([
                    "hyprctl",
                    "hyprpaper",
                    "preload",
                    "path"
                ])

                Quickshell.execDetached([
                    "hyprctl",
                    "hyprpaper",
                    "wallpaper",
                    "DP-2," + path
                ])

                Quickshell.execDetached([
                    "hyprctl",
                    "hyprpaper",
                    "wallpaper",
                    "DP-3," + path
                ])
            }
        }
    }
}