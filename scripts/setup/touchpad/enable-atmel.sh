#!/bin/bash

# This script reconfigures the Atmel maXTouch chips that control the touchscreen and
# touchpad input devices so they properly reset on boot.
# This should only be needed to be run once.

# See https://lkml.org/lkml/2016/4/7/786 for original thread.

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Elevate privileges if necessary
PROMPT=sudo
[ "$UID" -eq 0 ] || exec $PROMPT /bin/bash "$0" "$@"

# Load `i2c-dev` module to access I2C devices through /dev
$PROMPT modprobe i2c-dev &>/dev/null

[ -x "${DIR}/mxt-app" ]
if [ $? -eq 0 ]; then
  SCRIPT="${DIR}/mxt-app"
else
  command -v mxt-app >/dev/null 2>&1 || { echo >&2 "mxt-app not installed.  Aborting."; exit 1; }
  SCRIPT=mxt-app
fi
# Reset controllers
# Touchpad - seems to be using i2c dev 0 or 7
FOUND=0
DEV=0
while [ $FOUND -ne 1 ]; do
  OUT=$(echo -ne 'i\nq\n' | $PROMPT $SCRIPT -d i2c-dev:$DEV-004a 2>/dev/null)
  if [[ $OUT == *"Atmel maXTouch"* ]]; then
    FOUND=1
  else
    ((DEV++))
    if [ $DEV -gt 15 ]; then
      echo touchpad device not found - exiting
      exit 1
    fi
  fi
done
$PROMPT $SCRIPT -d i2c-dev:$DEV-004a -W -T18 44
$PROMPT $SCRIPT -d i2c-dev:$DEV-004a --backup
echo -----------------------------------------------
echo - touchpad device i2c-dev:$DEV-004a reconfigured -
echo -----------------------------------------------
echo
$PROMPT $SCRIPT -d i2c-dev:$((DEV+1))-004b -W -T18 44
$PROMPT $SCRIPT -d i2c-dev:$((DEV+1))-004b --backup
echo --------------------------------------------------
echo - touchscreen device i2c-dev:$((DEV+1))-004b reconfigured -
echo --------------------------------------------------
echo
echo DONE.
