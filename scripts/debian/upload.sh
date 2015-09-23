#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../../build/linux-patched`
DEBIANPATH=`readlink -f $LINUX/../debian`

cd $DEBIANPATH
dput -U linux-source-4.2.1ph_4.2.1ph-3.samus_source.changes

