#!/bin/sh

PYTHON=${PYTHON:-$(which python python|head -n 1) | sed 's/ /*/g'}

set -exv

# Usage info
show_help() {
cat << EOF
python [-h] [-p ESPTOOL_PORT] [-P PYTHON] [-f FILENAME|FILENAME]
Flash image file to device, but first erasing and writing system information"

    -h               Display this help and exit
    -p ESPTOOL_PORT  Set the environment variable for ESPTOOL_PORT.  If not set, ESPTOOL iterates all ports (Dangerrous).
    -P PYTHON        Specify alternate python interpreter to use to invoke esptool. (Default: "$PYTHON")
    -f FILENAME      The .bin file to flash.  Custom to your device type and region.
EOF
}


while getopts ":hp:P:f:" opt; do
    case "${opt}" in
        h)
            show_help
            exit 0
            ;;
        p)  export ESPTOOL_PORT=${OPTARG}
	    ;;
        P)  PYTHON=${OPTARG}
            ;;
        f)  FILENAME=${OPTARG}
            ;;
        *)
 	    echo "Invalid flag."
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

[ -z "$FILENAME" -a -n "$1" ] && {
    FILENAME=$1
    shift
}

if [ -f "${FILENAME}" ]; then
	echo "Trying to flash ${FILENAME}, but first erasing and writing system information"
	python -m esptool --baud 921600 erase_flash
	python -m esptool --baud 921600 write_flash 0x1000 system-info.bin
	python -m esptool --baud 921600 write_flash 0x00390000 spiffs-*50.bin
	python -m esptool --baud 921600 write_flash 0x10000 ${FILENAME}
else
	echo "Invalid file: ${FILENAME}"
	show_help
fi

exit 0
