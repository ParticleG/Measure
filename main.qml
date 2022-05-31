import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12

import QtCV 1.0
import FileIO 1.0
import StatusBar 1.0
import "functions.js" as Utils

ApplicationWindow {
    readonly property string defaultFontFamily: "Noto Sans CJK SC"
    property alias qtCV: qtcv
    property alias calculateCanvas: calculate_canvas
    property alias fileIO: fileio
    property alias toastDisplayer: toast_displayer
    property alias mainWindow: main_window
    property alias toolbarTitleLabel: toolbar_title_label
    property alias mainStackView: main_stackview

    id: main_window
    visible: true
    width: 540
    height: 1140
    title: qsTr("比甜度测量与运算工具")
    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    header: ToolBar {
        z: 5
        topPadding: Qt.platform.os === "ios" ? main_window.height
                                               - main_window.desktopAvailableHeight : 0
        contentHeight: drawer_button.implicitHeight
        ColumnLayout {
            anchors.fill: parent
            Rectangle {
                visible: Qt.platform.os === "ios"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                height: main_window.height - main_window.desktopAvailableHeight
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                ToolButton {
                    id: drawer_button
                    enabled: main_stackview.depth > 1 ? true : false
                    icon.source: main_stackview.depth > 1 ? "back.svg" : ""
                    icon.color: "white"
                    onClicked: {
                        if (main_stackview.depth > 1) {
                            main_stackview.pop()
                            if (main_stackview.depth === 1) {
                                main_stackview.get(0).restartAnimations()
                            }
                        }
                    }
                }
                Label {
                    id: toolbar_title_label
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: true
                    color: "#ffffff"
                    font.family: defaultFontFamily
                    font.pointSize: 20
                }
                ToolButton {
                    id: menu_button
                    icon.source: "dots-vertical.svg"
                    onClicked: {
                        if (main_stackview.depth > 1) {
                            toastDisplayer.show("Menu 2")
                        } else {
                            toastDisplayer.show("Menu 1")
                        }
                    }
                }
            }
        }
    }
    Canvas{
        z:15
        width: (parent.width - 20)
        height: (parent.width - 20) / 3 * 4
        id:calculate_canvas
        anchors.centerIn: parent

        property vector2d _centerPoint
        property vector4d _refractedLightLine

        function clear() {
            var ctx = getContext("2d");
            _centerPoint.x = 0
            _centerPoint.y = 0
            _refractedLightLine.x = 0
            _refractedLightLine.y = 0
            _refractedLightLine.z = 0
            _refractedLightLine.w = 0
            ctx.clearRect(0, 0, width, height);
        }

        function drawCVResult(_center, _refractedLight){
            var scale = (width / 2.0) / _center.x
            calculate_canvas.clear()
            _centerPoint.x = _center.x * scale
            _centerPoint.y = _center.y * scale
            _refractedLightLine.x = _refractedLight.x * scale
            _refractedLightLine.y = _refractedLight.y * scale
            _refractedLightLine.z = _refractedLight.z * scale
            _refractedLightLine.w = _refractedLight.w * scale

            calculate_canvas.requestPaint()
        }

        function animations(ctx) {
            ctx.lineWidth = 3
            ctx.strokeStyle = "lightgreen"
            ctx.beginPath()
            ctx.moveTo(_centerPoint.x, _centerPoint.y)
            ctx.lineTo(_refractedLightLine.x, _refractedLightLine.y)
            ctx.moveTo(_centerPoint.x, _centerPoint.y)
            ctx.lineTo(_refractedLightLine.z, _refractedLightLine.w)
            ctx.stroke()

            ctx.strokeStyle = "lightskyblue"
            ctx.beginPath()
            ctx.moveTo(_refractedLightLine.x, _refractedLightLine.y)
            ctx.lineTo(_refractedLightLine.z, _refractedLightLine.w)
            ctx.stroke()

            ctx.fillStyle = "lightsalmon"
            ctx.beginPath()
            ctx.arc(_centerPoint.x, _centerPoint.y, 2, 0, Math.PI * 2.0, false)
            ctx.fill()
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            calculate_canvas.animations(ctx)
        }
    }

    Label {
        z:15
        width: (parent.width - 20)
        id: result_label
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
    }

    QtCV {
        id: qtcv
        onProcessCompleted: {
            console.log(_center)
            console.log(_refractedLight)
            calculate_canvas.drawCVResult(_center,_refractedLight)
//            var sweetness = 30.0 / (Math.sin(_angle) * 29.0) * 6.14 - 7.4432
            var sweetness = 30.0 / (Math.sin(_angle) * 29.0) * 6.14 - 8.2
            toast_displayer.show("角度：" + _angle.toFixed(4) + "，甜度：" + sweetness.toFixed(4))
            result_label.text = "角度：" + _angle.toFixed(4) + "，甜度：" + sweetness.toFixed(4)
        }
    }
    FileIO {
        id: fileio
    }
    StatusBar {
        theme: "Dark"
        color: Material.color(Material.Indigo, Material.Shade700)
    }
    ToastManager {
        id: toast_displayer
    }
    StackView {
        id: main_stackview
        z: 10
        initialItem: "MainStackView.qml"
        anchors.fill: parent
        onDepthChanged: {
            toolbar_title_label.text = main_stackview.get(main_stackview.depth - 1).title
            if (main_stackview.get(main_stackview.depth - 1).title === "图像处理") {
                calculate_canvas.clear()
                calculate_canvas.visible = true
                result_label.visible = true
            } else {
                calculate_canvas.clear()
                calculate_canvas.visible = false
                result_label.visible = false
            }
        }
    }
}
