#!/bin/bash

# see: https://github.com/GalliumOS/galliumos-distro/issues/100#issuecomment-241534837:

CARD="$(aplay -l | grep -Eo '^card ([0-9]): bdwrt5677' | sed 's/card //' | sed 's/:.*$//')"

amixer -c $CARD cset name='Headphone Switch' off
amixer -c $CARD cset name='Stereo DAC MIXL DAC1 L Switch' off
amixer -c $CARD cset name='Stereo DAC MIXR DAC1 R Switch' off
amixer -c $CARD cset name='Stereo DAC MIXL DAC1 R Switch' on
amixer -c $CARD cset name='Stereo DAC MIXR DAC1 L Switch' on
amixer -c $CARD cset name='Speaker Switch' on
