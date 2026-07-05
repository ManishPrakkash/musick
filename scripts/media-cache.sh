#!/usr/bin/env bash
set -euo pipefail
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/musick"
INFO_FILE="$CACHE_DIR/info"
STATE_FILE="$CACHE_DIR/state"
COVER_FILE="$CACHE_DIR/cover.jpg"
TRACK_FILE="$CACHE_DIR/track_id"
TMP_COVER="$CACHE_DIR/cover.tmp"
mkdir -p "$CACHE_DIR"

hide_widget() {
  echo "hidden" > "$STATE_FILE"
  printf "\n\n\n" > "$INFO_FILE"
  rm -f "$COVER_FILE" "$TMP_COVER" "$TRACK_FILE"
  exit 0
}

PLAYER="$(playerctl -l 2>/dev/null | while read -r p; do
  status="$(playerctl -p "$p" status 2>/dev/null || true)"
  [ "$status" = "Playing" ] && echo "$p" && break
done)"
[ -z "${PLAYER:-}" ] && hide_widget
STATUS="$(playerctl -p "$PLAYER" status 2>/dev/null || true)"
[ "$STATUS" != "Playing" ] && hide_widget

TITLE="$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null || true)"
ARTIST="$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null || true)"
PLAYER_NAME="$(playerctl -p "$PLAYER" metadata --format '{{playerName}}' 2>/dev/null || true)"
ART_URL="$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null || true)"
TRACK_ID="$(playerctl -p "$PLAYER" metadata mpris:trackid 2>/dev/null || true)"
[ -z "$TITLE" ] && hide_widget
[ -z "$ARTIST" ] && ARTIST="Unknown Artist"
[ -z "$PLAYER_NAME" ] && PLAYER_NAME="Media"
[ -z "$TRACK_ID" ] && TRACK_ID="${TITLE}_${ARTIST}"

printf "%s\n%s\n%s\n" "$(printf '%s' "$TITLE" | cut -c1-120)" "$(printf '%s' "$ARTIST" | cut -c1-80)" "$PLAYER_NAME" > "$INFO_FILE"
echo "show" > "$STATE_FILE"
OLD_TRACK=""
[ -f "$TRACK_FILE" ] && OLD_TRACK="$(cat "$TRACK_FILE" 2>/dev/null || true)"
echo "$TRACK_ID" > "$TRACK_FILE"

if [ "$TRACK_ID" != "$OLD_TRACK" ] || [ ! -f "$COVER_FILE" ]; then
  rm -f "$TMP_COVER"
  if [ -n "$ART_URL" ]; then
    if [[ "$ART_URL" == file://* ]]; then
      LOCAL_PATH="${ART_URL#file://}"
      LOCAL_PATH="$(python3 -c 'import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))' "$LOCAL_PATH" 2>/dev/null || echo "$LOCAL_PATH")"
      [ -f "$LOCAL_PATH" ] && cp "$LOCAL_PATH" "$TMP_COVER" 2>/dev/null || true
    elif [[ "$ART_URL" == data:image/*;base64,* ]]; then
      B64_DATA="${ART_URL#*,}"
      python3 -c 'import urllib.parse, base64, sys; sys.stdout.buffer.write(base64.b64decode(urllib.parse.unquote(sys.argv[1])))' "$B64_DATA" > "$TMP_COVER" 2>/dev/null || true
    else
      command -v curl >/dev/null 2>&1 && curl -L --silent --max-time 5 --output "$TMP_COVER" "$ART_URL" 2>/dev/null || true
    fi
    [ -f "$TMP_COVER" ] && mv "$TMP_COVER" "$COVER_FILE" || rm -f "$COVER_FILE"
  else
    rm -f "$COVER_FILE"
  fi
fi
