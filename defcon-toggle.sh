#!/bin/bash
STREAM_URL="https://ice.somafm.com/defcon"
MPRIS_SCRIPT="/usr/share/mpv/scripts/mpris.so"

# If mpv is already playing this stream, stop it;
# otherwise start it with MPRIS so End-4 can see it.
if pgrep -a mpv | grep -q "$STREAM_URL"; then
  # stop the specific mpv instance for this stream
  pkill -f "mpv .*${STREAM_URL}"
else
  # detach and silence stdout/stderr
  setsid mpv \
    --no-video \
    --force-media-title="SomaFM: DEF CON Radio" \
    --script="$MPRIS_SCRIPT" \
    "$STREAM_URL" >/dev/null 2>&1 &
fi
