#!/bin/bash

# see: https://github.com/GalliumOS/galliumos-distro/issues/100#issuecomment-241534837:

amixer -c 0 cset name='DAC1 MIXL DAC1 Switch' on
amixer -c 0 cset name='DAC1 MIXR DAC1 Switch' on
