import QtQuick 2.12


/**
 * @brief Manager that creates Toasts dynamically
 */
Column {


	/**
	 * Public
	 */


	/**
	 * @brief Shows a Toast
	 *
	 * @param {string} text Text to show
	 * @param {real} duration Duration to show in milliseconds, defaults to 3000
	 */
	function show(text, duration) {
		var toast = toastComponent.createObject(toast_manager_root)
		toast.selfDestroying = true
		toast.show(text, duration)
	}


	/**
	 * Private
	 */
	id: toast_manager_root

	z: Infinity
	spacing: 5
	anchors.bottom: parent.bottom
	anchors.bottomMargin: 10
	anchors.horizontalCenter: parent.horizontalCenter
	property var toastComponent

	Component.onCompleted: toastComponent = Qt.createComponent("Toast.qml")
}
/*##^##
Designer {
	D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

