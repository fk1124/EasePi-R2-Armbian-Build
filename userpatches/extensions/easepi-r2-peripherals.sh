# EasePi-R2 Peripherals Extension: IR + AP6255 Bluetooth
# This extension intentionally keeps the classic userpatches/extensions/*.sh path
# for broad Armbian compatibility, while reading overlay files from the kit's
# userpatches/overlay/easepi-r2-peripherals directory.

function extension_prepare_config__easepi_r2_peripherals() {
	display_alert "Extension: EasePi-R2 Peripherals" "IR + Bluetooth support" "info"
}

function pre_customize_image__copy_easepi_r2_peripheral_files() {
	display_alert "EasePi-R2" "Copying peripheral overlay files" "info"

	local OVERLAY_DIR=""

	# Preferred path inside the active Armbian build tree.
	if [[ -n "${SRC:-}" && -d "${SRC}/userpatches/overlay/easepi-r2-peripherals" ]]; then
		OVERLAY_DIR="${SRC}/userpatches/overlay/easepi-r2-peripherals"
	# Fallback: if EXTENSION_DIR is available and overlay sits next to extension.
	elif [[ -n "${EXTENSION_DIR:-}" && -d "${EXTENSION_DIR}/overlay" ]]; then
		OVERLAY_DIR="${EXTENSION_DIR}/overlay"
	fi

	if [[ -z "${OVERLAY_DIR}" || ! -d "${OVERLAY_DIR}" ]]; then
		display_alert "EasePi-R2" "Peripheral overlay not found; skipping IR/BT files" "wrn"
		return 0
	fi

	mkdir -p "${SDCARD}"
	cp -a "${OVERLAY_DIR}/." "${SDCARD}/"

	if [[ -f "${SDCARD}/usr/local/sbin/bluetooth-hciattach.sh" ]]; then
		chmod +x "${SDCARD}/usr/local/sbin/bluetooth-hciattach.sh"
	fi

	if [[ -f "${SDCARD}/usr/local/ir/fix_infrared.sh" ]]; then
		chmod +x "${SDCARD}/usr/local/ir/fix_infrared.sh"
	fi
}

function post_customize_image__enable_easepi_r2_peripheral_services() {
	display_alert "EasePi-R2" "Enabling peripheral services" "info"

	if [[ -f "${SDCARD}/etc/systemd/system/ir-keymap.service" ]]; then
		chroot_sdcard systemctl enable ir-keymap.service || true
	fi

	if [[ -f "${SDCARD}/etc/systemd/system/bluetooth-hciattach.service" ]]; then
		chroot_sdcard systemctl enable bluetooth-hciattach.service || true
	fi

	chroot_sdcard systemctl enable bluetooth.service || true
}
