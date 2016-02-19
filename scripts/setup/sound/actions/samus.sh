#!/bin/sh
# ACPI script for dynamic sound output switching between speakers and headphones

set "$@"

log_unhandled() {
    logger "ACPI event unhandled: $*"
}

switchPulsePort() {
    SINK="alsa_output.platform-bdw-rt5677.analog-stereo"
    PORT="analog-output-speaker"

    if [ "x$1" = "xplug" ] ; then
        PORT="analog-output-headphones"
    fi

    for USER in $(ps axc -o user,command | grep pulseaudio | cut -f1 -d' ' | sort | uniq)
    do
        PULSE_RUNTIME_PATH=$(find /tmp -name "pulse-*" -type d -readable -prune)
        PULSE_RUNTIME_PATH=${PULSE_RUNTIME_PATH:-"/run/user/$(id -u $USER)/pulse/"}
        su "${USER}" -c "PULSE_RUNTIME_PATH=${PULSE_RUNTIME_PATH} pacmd set-sink-port ${SINK} ${PORT}"
    done
}

case "$1" in
    jack/headphone)
        case "$3" in
            plug)
                logger "headphone plugged"
                switchPulsePort "$3"
                ;;
            unplug)
                logger "headphone unplugged"
                switchPulsePort "$3"
                ;;
            *)
                log_unhandled "$@"
                ;;
        esac
        ;;
    *)  log_unhandled "$@"
        ;;
esac
