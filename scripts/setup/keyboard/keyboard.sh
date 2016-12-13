#!/bin/bash
# Copyright (c) 2016 The crouton Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This adds support for Chromebook keyboard special keys.  It operates
# on the current user account (not a systemwide setting).
#
# For example, we map Search+arrows to Page Up/Down/Home/End. This is
# done at the browser level in Chromium OS (i.e., not at the hardware
# or keymap level).
#
# The mapping of Search+F1-F10 is reversed compared to Chromium OS:
# Pressing the back key still produces F1, Search+F1 is required to
# generate XF86Back.
#
# We do this by adding an overlay, and using Super_L (Search key) as
# the overlay latch.
#
# An additional mapping is needed to make sure that Super_R is not
# sent when the Search key is released (this is a little strange,
# and I'm not sure why this happens).

set -euo pipefail

XSESSIONRC="${HOME}/.xsessionrc"
XKBROOT="${HOME}/.xkb"

if [ -e "${XKBROOT}" ]; then
    echo "${XKBROOT} already exists; refusing to overwrite it"
    exit 1
fi

mkdir -p "${XKBROOT}"/{symbols,keymap,compat}

# for xkb_compat and xkb_symbols, add "+chromebook":
# 'xkb_compat    { include "complete" };' ->
# 'xkb_compat    { include "complete+chromebook" };'
setxkbmap -print | \
    perl -wpe 'm/xkb_(compat)|(symbols)/ && s/"(.+?)"/"$1+chromebook"/' > \
    "${XKBROOT}/keymap/chromebook"

cat > "${XKBROOT}/compat/chromebook" <<END
// Overlay1_Enable is a latch key for overlay1

default partial xkb_compatibility "overlay"  {
    interpret Overlay1_Enable+AnyOfOrNone(all) {
        action= SetControls(controls=Overlay1);
    };
};
END

cat > "${XKBROOT}/symbols/chromebook" <<END
// This mapping assumes that inet(evdev) will also be sourced
partial
xkb_symbols "overlay" {
    key <LWIN> { [ Overlay1_Enable ], overlay1=<LWIN> };

    key <AB09> { overlay1=<INS> };

    key <LEFT> { overlay1=<HOME> };
    key <RGHT> { overlay1=<END> };
    key <UP>   { overlay1=<PGUP> };
    key <DOWN> { overlay1=<PGDN> };

    key <FK01> { overlay1=<I247> };
    key <I247> { [ XF86Back ] };
    key <FK02> { overlay1=<I248> };
    key <I248> { [ XF86Forward ] };
    key <FK03> { overlay1=<I249> };
    key <I249> { [ XF86Reload ] };
    key <FK04> { overlay1=<I235> }; // XF86Display
    key <FK05> { overlay1=<I250> };
    key <I250> { [ XF86ApplicationRight ] };
    key <FK06> { overlay1=<I232> }; // XF86MonBrightnessDown
    key <FK07> { overlay1=<I233> }; // XF86MonBrightnessUp
    key <FK08> { overlay1=<MUTE> };
    key <FK09> { overlay1=<VOL-> };
    key <FK10> { overlay1=<VOL+> };

    key <AE01> { overlay1=<FK01> };
    key <AE02> { overlay1=<FK02> };
    key <AE03> { overlay1=<FK03> };
    key <AE04> { overlay1=<FK04> };
    key <AE05> { overlay1=<FK05> };
    key <AE06> { overlay1=<FK06> };
    key <AE07> { overlay1=<FK07> };
    key <AE08> { overlay1=<FK08> };
    key <AE09> { overlay1=<FK09> };
    key <AE10> { overlay1=<FK10> };
    key <AE11> { overlay1=<FK11> };
    key <AE12> { overlay1=<FK12> };
    key <BKSP> { overlay1=<DELE> };

    key <LALT> { overlay1=<CAPS> };
    key <RALT> { overlay1=<CAPS> };

    // For some strange reason, some Super_R events are triggered when
    // the Search key is released (i.e. with overlay on).
    // This maps RWIN to a dummy key (<I253>), to make sure we catch it.
    key <RWIN> { [ NoSymbol ], overlay1=<I253> };

    // Map dummy key to no symbol
    key <I253> { [ NoSymbol ] };
};
END

touch "${XSESSIONRC}"
if ! grep -q xkbcomp "${XSESSIONRC}"; then
    echo 'xkbcomp -I${HOME}/.xkb -R${HOME}/.xkb keymap/chromebook ${DISPLAY}' >> \
        "$XSESSIONRC"
fi

echo "Done.  Log out and log back in to test."
echo "If there are issues: rm -rf ~/.xsessionrc ~/.xkb"

exit 0
