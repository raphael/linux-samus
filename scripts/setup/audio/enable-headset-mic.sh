#!/bin/bash

# see: https://github.com/GalliumOS/galliumos-distro/issues/100#issuecomment-241534837

amixer -c 0 cset name='Sto1 ADC MIXL ADC2 Switch' off
amixer -c 0 cset name='Sto1 ADC MIXR ADC2 Switch' off
amixer -c 0 cset name='Local DMICs Switch' off
amixer -c 0 cset name='Remote DMICs Switch' off
amixer -c 0 cset name='IF1 ADC1 Swap Mux' L/L
amixer -c 0 cset name='Sto1 ADC MIXL ADC1 Switch' on
amixer -c 0 cset name='Sto1 ADC MIXL ADC1 Switch' on
amixer -c 0 cset name='Headset Mic Switch' on

