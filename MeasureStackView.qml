import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import "functions.js" as Utils

Page {
    id: measure_stackview_page
    title: qsTr("甜度测量")
    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: parent.width * 3.0 / 4.0
            Layout.fillWidth: true
            Camera {
                id: preview_camera
                focus {
                    focusMode: Camera.FocusContinuous
                    focusPointMode: Camera.FocusPointAuto
                }
                exposure.exposureMode: Camera.ExposurePortrait
                imageProcessing {
                    denoisingLevel: 0.5
                    brightness: -0.5
                }
                imageCapture {
                    onImageCaptured: {
                        console.log("Image captured")
                    }
                    onImageSaved: {
                        console.log("Image saved")
                        toastDisplayer.show("图像保存在\n/storage/emulated/0/\nAndroid/data/cn.hdustea.measure/")
                        mainStackView.push("CalculateStackView.qml");
                    }
                }
            }
            Rectangle {
                z: 0
                anchors.centerIn: parent
                width: (parent.width - 20)
                height: (parent.width - 20) / 3 * 4
                color: "darkgray"
                ToolButton {
                    z: 1
                    anchors.centerIn: parent
                    icon.source: "camera-off.svg"
                    icon.color: "dimgrey"
                    icon.width: parent.width / 3
                    icon.height: parent.width / 3
                    enabled: false
                    checkable: false
                    down: false
                    hoverEnabled: false
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.y + 300
                    text: "No Camera Permission"
                    font.pointSize: 22
                }
                VideoOutput {
                    z: 10
                    source: preview_camera
                    anchors.fill: parent
                    autoOrientation: true
                    focus: visible // to receive focus and capture key events when visible
                }
                Canvas{
                    z:15
                    id:indicator_canvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        var centreX = width / 2;
                        var centreY = height / 2;

                        ctx.lineWidth = 3
                        ctx.strokeStyle = "lightgreen";

                        ctx.beginPath();
                        ctx.moveTo(10, centreY);
                        ctx.lineTo(width - 10, centreY)
                        ctx.moveTo(centreX, centreY - width / 2 + 10.0);
                        ctx.lineTo(centreX, centreY + width / 2 - 10.0)
                        ctx.stroke();

                        ctx.strokeStyle = "lightsalmon";

                        ctx.beginPath();
                        ctx.arc(centreX, centreY, width / 2 - 10.0, 0, Math.PI * 2.0, false);
                        ctx.stroke();

                        ctx.strokeStyle = "lightskyblue";

                        ctx.beginPath();
                        ctx.arc(centreX, centreY, width / 3, 0, Math.PI * 0.5, false);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(centreX, centreY, width / 3, Math.PI * 1.0, Math.PI * 1.5, false);
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.arc(centreX, centreY, width / 4, 0, Math.PI * 0.5, false);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(centreX, centreY, width / 4, Math.PI * 1.0, Math.PI * 1.5, false);
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.arc(centreX, centreY, width / 6, 0, Math.PI * 0.5, false);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(centreX, centreY, width / 6, Math.PI * 1.0, Math.PI * 1.5, false);
                        ctx.stroke();
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Label {
                text: qsTr("曝光补偿：")
            }

            Label {
                id: exposureControl_label

            }

            Slider {
                id: exposureControl_slider
                width: parent.width / 3.0 * 2.0
                from: -5.0
                to: 5.0
                stepSize: 0.1
                value: 0.0
                onMoved: {
                    preview_camera.exposure.exposureCompensation = value.toFixed(1)
                    exposureControl_label.text = value.toFixed(1)
                }
            }

            Button {
                id: capture_button
                text: "拍摄图像"
                onClicked: {
                    if(!fileIO.ensure("/storage/emulated/0/Android/data/cn.hdustea.measure")) {
                        console.log("Create Folder Failed!")
                    } else {
                        fileIO.write("/storage/emulated/0/Android/data/cn.hdustea.measure/.nomedia","");
                    }
                    preview_camera.imageCapture.captureToLocation("/storage/emulated/0/Android/data/cn.hdustea.measure/rawImage.jpg")
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
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

