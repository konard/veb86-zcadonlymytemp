#!/usr/bin/env bash
# issue #3: снимок окон менеджера стилей мультивыносок под Xvfb.
# Запускает собранный zcad со скриптом: загрузка acadsave2007.dxf и команда
# MLeaderStyles или MLeaderStyleManager; снимает экран через ImageMagick.
#
# Использование:
#   experiments/mleaderstyles_screenshot.sh <каталог bin zcad> <команда> <png>
# Пример:
#   experiments/mleaderstyles_screenshot.sh /tmp/zcadbuild/cad/bin/x86_64-linux \
#     MLeaderStyles docs/screenshots/mleaderstyles.png
set -euo pipefail

BIN=$1
CMD=$2
PNG=$(realpath -m "$3")
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DISP=${DISP:-:99}
WAIT=${WAIT:-25}

SCRIPT=$(mktemp --suffix=.cmd)
printf 'Load(%s)\n%s\n' "$ROOT/acadsave2007.dxf" "$CMD" > "$SCRIPT"

Xvfb "$DISP" -screen 0 1280x800x24 >/dev/null 2>&1 &
XPID=$!
trap 'kill $ZPID $XPID 2>/dev/null || true; rm -f "$SCRIPT"' EXIT
sleep 2

cd "$BIN"
DISPLAY=$DISP ./zcad nosplash runscript "$SCRIPT" > /tmp/zcad-screenshot.log 2>&1 &
ZPID=$!
sleep "$WAIT"

mkdir -p "$(dirname "$PNG")"
DISPLAY=$DISP import -window root "$PNG"
echo "saved $PNG"
