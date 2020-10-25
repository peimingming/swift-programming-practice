#!/bin/bash

# sh to search and filter .plist/.strings files. by a designated keyword
#
# Usage:
# 1. Copy all the .plist files which need to be filtered into a same folder with the sh file, i.e. `ErrorCodes.plist`.
# 2. Copy all the .strings files which need to be filterd into a same folder with the sh file, and insert the language infix `-en`, `-zh_Hant` and `-zh_Hans` for the 3 languages respectively, in order for recognizing the languages by the system, i.e. `ErrorCodes.strings` -> `ErrorCodes-en.strings`, `ErrorCodes-zh_Hant.strings`, `ErrorCodes-zh_Hans.strings`.
# 3. Execute `sh filter.sh [keyword]`, i.e. `sh filter.sh failed` (to search and filter the en copy with the keyword `failed`, and also filter out the corresponding other 2 languages copy).

top=$(dirname $0)
keyword=$1

function filter {
    /usr/bin/env xcrun --sdk macosx swift ${top}/Filter.swift $top $keyword
}

if [ -z $keyword ]; then
    read -p "Please input a keyword to be used:" keyword
    filter
else
    filter
fi
