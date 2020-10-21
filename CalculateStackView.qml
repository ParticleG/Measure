import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import "functions.js" as Utils

Page {
    id: calculate_stackview_page
    title: qsTr("图像处理")
    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: width
            Layout.fillWidth: true
            Rectangle {
                z: 0
                anchors.centerIn: parent
                width: (parent.width - 20)
                height: (parent.width - 20) / 3 * 4
                color: "darkgray"
                Image {
                    id: processed_image
                    z: 10
                    cache: false
                    autoTransform: true
                    source: "file:///storage/emulated/0/Android/data/cn.hdustea.measure/rawImage.jpg"
                    anchors.fill: parent
                }
                BusyIndicator {
                    z: 12
                    id: imageProcessing_busyIndicator
                    anchors.centerIn: parent
                    width: parent.width / 6.0
                    height: width
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.y + 300
                    text: qsTr("正在处理图片……")
                    font.pointSize: 22
                }
            }
        }
    }
    Timer {
        id: cv_timer
        interval: 500
        repeat: false
        onTriggered: {
            qtCV.processImage("/storage/emulated/0/Android/data/cn.hdustea.measure/rawImage.jpg")
            imageProcessing_busyIndicator.visible = false
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
    Component.onCompleted: {
        cv_timer.restart()
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

