#!/bin/bash

# see: https://github.com/GalliumOS/galliumos-distro/issues/100#issuecomment-241534837:

CARD="$(aplay -l | grep -Eo '^card ([0-9]): bdwrt5677' | sed 's/card //' | sed 's/:.*$//')"

amixer -c $CARD cset name='DAC1 MIXL DAC1 Switch' on
amixer -c $CARD cset name='DAC1 MIXR DAC1 Switch' on
