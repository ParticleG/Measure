import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import "functions.js" as Utils

Page {
    property var basic_button_diameter: (mainWindow.width / 3)
    property var start_y_axe: mainWindow.width / 10
    id: main_stackview_page
    title: qsTr("选择功能")
    Item {
        id: splash_item
        anchors.fill: parent
        ColumnLayout {
            anchors.centerIn: parent
            RoundButton {
                z: 12
                id: start_measuring_roundbutton
                Layout.preferredWidth: basic_button_diameter
                Layout.preferredHeight: basic_button_diameter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.family: defaultFontFamily
                font.bold: true
                font.capitalization: Font.MixedCase
                highlighted: true
                display: AbstractButton.TextUnderIcon
                text: qsTr("开始测量")
                icon.height: basic_button_diameter / 2
                icon.width: basic_button_diameter / 2
                opacity: 0
                SequentialAnimation on y {
                    id: button_move_animation
                    alwaysRunToEnd: true
                    PropertyAnimation {
                        from: start_y_axe
                        to: start_y_axe + 50
                        duration: 1000
                        easing.type: Easing.OutCubic
                    }
                }
                SequentialAnimation on opacity {
                    id: button_opacity_animation
                    alwaysRunToEnd: true
                    PropertyAnimation {
                        from: 0
                        to: 1
                        duration: 1000
                        easing.type: Easing.OutCubic
                    }
                }
                onClicked: {
                    mainStackView.push("MeasureStackView.qml")
                }
            }
            ToolButton {
                z: 11
                icon.source: "beaker.svg"
                icon.color: Material.color(Material.Blue)
                icon.width: basic_button_diameter * 3
                icon.height: basic_button_diameter * 3
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                opacity: 0
                enabled: false
                checkable: false
                down: false
                hoverEnabled: false
                SequentialAnimation on y {
                    id: splash_move_animation
                    alwaysRunToEnd: true
                    PropertyAnimation {
                        from: start_y_axe + 150
                        to: start_y_axe + 200
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
                SequentialAnimation on opacity {
                    id: splash_opacity_animation
                    alwaysRunToEnd: true
                    PropertyAnimation {
                        from: 0
                        to: 1
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
    Keys.onPressed: {
        if (event.key === Qt.Key_Back) {
            event.accepted = true
            if (main_stackview.depth > 1) {
                main_stackview.pop()
                if (main_stackview.depth === 1) {
                    main_stackview.get(0).restartAnimations()
                }
            } else {
                Qt.quit()
            }
        }
    }
    focus: true
    function restartAnimations() {
        splash_move_animation.restart()
        splash_opacity_animation.restart()
        button_move_animation.restart()
        button_opacity_animation.restart()
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

