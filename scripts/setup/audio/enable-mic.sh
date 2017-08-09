#!/bin/bash

# see: https://github.com/GalliumOS/galliumos-distro/issues/100#issuecomment-241534837

CARD="$(aplay -l | grep -Eo '^card ([0-9]): bdwrt5677' | sed 's/card //' | sed 's/:.*$//')"

amixer -c $CARD cset name='Sto1 ADC MIXL ADC1 Switch' off
amixer -c $CARD cset name='Sto1 ADC MIXR ADC1 Switch' off
amixer -c $CARD cset name='Headset Mic Switch' off
amixer -c $CARD cset name='IF1 ADC1 Swap Mux' L/R
amixer -c $CARD cset name='Sto1 ADC MIXL ADC2 Switch' on
amixer -c $CARD cset name='Sto1 ADC MIXL ADC2 Switch' on
amixer -c $CARD cset name='Local DMICs Switch' on
amixer -c $CARD cset name='Remote DMICs Switch' on

