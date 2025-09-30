#!/usr/bin/env bash
# somafm.sh — single-instance SomaFM toggle with a commented station list
# Dependencies: mpv, mpv-mpris
#   pacman -S mpv mpv-mpris

MPRIS_SCRIPT="/usr/share/mpv/scripts/mpris.so"
SOCKET="/tmp/mpv-somafm.sock"   # identifies our single player instance

############################################
# PICK ONE STATION (uncomment exactly one) #
############################################

#STATION="DEFCON"
STATION="GrooveSalad"
#STATION="DroneZone"
#STATION="DeepSpaceOne"
#STATION="SpaceStation"
#STATION="MissionControl"
#STATION="Lush"
#STATION="SecretAgent"
#STATION="Underground80s"

############################################
# Station URL map (direct MP3 HTTPS URLs)  #
############################################
station_url() {
  case "$1" in
    DEFCON)         echo "https://ice.somafm.com/defcon-256-mp3" ;;
    GrooveSalad)    echo "https://ice.somafm.com/groovesalad-256-mp3" ;;
    DroneZone)      echo "https://ice.somafm.com/dronezone-128-mp3" ;;
    DeepSpaceOne)   echo "https://ice.somafm.com/deepspaceone-128-mp3" ;;
    SpaceStation)   echo "https://ice.somafm.com/spacestation-320-mp3" ;;
    MissionControl) echo "https://ice.somafm.com/missioncontrol-128-mp3" ;;
    Lush)           echo "https://ice.somafm.com/lush-128-mp3" ;;
    SecretAgent)    echo "https://ice.somafm.com/secretagent-128-mp3" ;;
    Underground80s) echo "https://ice.somafm.com/u80s-128-mp3" ;;
    *)              return 1 ;;
  esac
}

station_title() {
  case "$1" in
    DEFCON)         echo "SomaFM: DEF CON Radio" ;;
    GrooveSalad)    echo "SomaFM: Groove Salad" ;;
    DroneZone)      echo "SomaFM: Drone Zone" ;;
    DeepSpaceOne)   echo "SomaFM: Deep Space One" ;;
    SpaceStation)   echo "SomaFM: Space Station Soma" ;;
    MissionControl) echo "SomaFM: Mission Control" ;;
    Lush)           echo "SomaFM: Lush" ;;
    SecretAgent)    echo "SomaFM: Secret Agent" ;;
    Underground80s) echo "SomaFM: Underground 80s" ;;
    *)              return 1 ;;
  esac
}

############################################
# Internals                                #
############################################

mpv_running() {
  # is there an mpv that was launched with our socket?
  pgrep -a mpv | grep -q -- "$SOCKET"
}

start_mpv() {
  local name="$1" url title
  url="$(station_url "$name")"   || { echo "Unknown station '$name'"; exit 2; }
  title="$(station_title "$name")"
  # Fixed station name in the header; ICY song titles are ignored.
  setsid mpv \
    --no-video \
    --script="$MPRIS_SCRIPT" \
    --input-ipc-server="$SOCKET" \
    --force-media-title="$title" \
    "$url" >/dev/null 2>&1 &
  disown
}

stop_mpv() {
  # kill only our instance, regardless of what URL it’s playing
  pkill -f "$SOCKET" 2>/dev/null || true
  [ -S "$SOCKET" ] && rm -f "$SOCKET"
}

############################################
# Commands                                 #
############################################
# Usage:
#   somafm.sh             # toggle (uses STATION chosen above)
#   somafm.sh --set NAME  # switch to station NAME (from the list) even if playing
#   somafm.sh --stop      # stop playback

case "$1" in
  --stop)
    stop_mpv
    ;;
  --set)
    # switch station: restart our single instance with the new one
    target="$2"
    [ -z "$target" ] && { echo "Usage: $0 --set <StationName>"; exit 2; }
    stop_mpv
    start_mpv "$target"
    ;;
  "")
    # toggle using the chosen STATION
    [ -z "$STATION" ] && { echo "Pick a STATION inside this script (uncomment one)."; exit 2; }
    if mpv_running; then
      stop_mpv
    else
      start_mpv "$STATION"
    fi
    ;;
  *)
    echo "Usage: $0 [--set <StationName>|--stop]" >&2
    exit 2
    ;;
esac
