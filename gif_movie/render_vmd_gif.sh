#!/usr/bin/env bash

# Render a VMD state and AMBER NetCDF trajectory, then assemble an animated GIF.
# The companion Tcl script performs frame sampling, alignment and Tachyon rendering.

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
START_DIR=$(pwd -P)

STATE_FILE=""
TRAJECTORY_FILE=""
TCL_FILE="$SCRIPT_DIR/render_comp9_frames.tcl"
OUTPUT_FILE=""
FRAMES_DIR=""
LOG_FILE=""
VMD_BIN="${VMD_BIN:-}"
FFMPEG_BIN="${FFMPEG_BIN:-}"
NCDUMP_BIN="${NCDUMP_BIN:-}"
TOTAL_FRAMES=""
SAMPLE_COUNT=""
DURATION_SECONDS="15"
FPS="12"
WIDTH="800"
HEIGHT="600"
ALIGN_SELECTION="(nucleic) and noh"
SMOOTH_RADIUS="5"

usage() {
    cat <<'EOF'
Usage:
  ./render_vmd_gif.sh [options]

Required inputs are auto-detected when the working directory contains exactly
one .vmd state and one .nc trajectory. Use --state and --trajectory otherwise.

Options:
  --state FILE             VMD state file containing the topology and display setup
  --trajectory FILE        AMBER NetCDF trajectory used by the state
  --tcl FILE               Companion rendering Tcl script
  --output FILE            Output GIF (default: data/processed/STATE_md_15s.gif)
  --frames-dir DIR         Intermediate TGA directory (kept after completion)
  --log FILE               VMD render log
  --duration SECONDS       Requested GIF duration; default: 15
  --fps RATE               GIF frame rate; default: 12
  --samples COUNT          Rendered frame count; overrides duration x fps
  --width PIXELS           GIF width; default: 800
  --height PIXELS          GIF height; default: 600
  --align-selection TEXT   Selection fitted to Top frame 0
                            default: (nucleic) and noh
  --no-align               Do not align the trajectory
  --smooth-radius COUNT    Adjacent source frames loaded on each side; default: 5
  --total-frames COUNT     Source frame count; normally read using ncdump
  --vmd FILE               VMD executable
  --ffmpeg FILE            ffmpeg executable
  --ncdump FILE            ncdump executable
  -h, --help               Show this help

Examples:
  ./render_vmd_gif.sh

  ./render_vmd_gif.sh \
    --state system.vmd --trajectory production.nc \
    --output data/processed/system.gif

  ./render_vmd_gif.sh \
    --state protein.vmd --trajectory protein.nc \
    --align-selection 'protein and name CA' --duration 20 --fps 15

The state file must contain exactly one "mol addfile ... type netcdf" command.
Relative topology paths in the state are resolved from the state's directory.
EOF
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

require_value() {
    [[ $# -ge 2 ]] || die "Option $1 requires a value"
}

make_absolute() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *)  printf '%s/%s\n' "$START_DIR" "$1" ;;
    esac
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --state)
            require_value "$@"
            STATE_FILE=$2
            shift 2
            ;;
        --trajectory)
            require_value "$@"
            TRAJECTORY_FILE=$2
            shift 2
            ;;
        --tcl)
            require_value "$@"
            TCL_FILE=$2
            shift 2
            ;;
        --output)
            require_value "$@"
            OUTPUT_FILE=$2
            shift 2
            ;;
        --frames-dir)
            require_value "$@"
            FRAMES_DIR=$2
            shift 2
            ;;
        --log)
            require_value "$@"
            LOG_FILE=$2
            shift 2
            ;;
        --duration)
            require_value "$@"
            DURATION_SECONDS=$2
            shift 2
            ;;
        --fps)
            require_value "$@"
            FPS=$2
            shift 2
            ;;
        --samples)
            require_value "$@"
            SAMPLE_COUNT=$2
            shift 2
            ;;
        --width)
            require_value "$@"
            WIDTH=$2
            shift 2
            ;;
        --height)
            require_value "$@"
            HEIGHT=$2
            shift 2
            ;;
        --align-selection)
            require_value "$@"
            ALIGN_SELECTION=$2
            shift 2
            ;;
        --no-align)
            ALIGN_SELECTION=""
            shift
            ;;
        --smooth-radius)
            require_value "$@"
            SMOOTH_RADIUS=$2
            shift 2
            ;;
        --total-frames)
            require_value "$@"
            TOTAL_FRAMES=$2
            shift 2
            ;;
        --vmd)
            require_value "$@"
            VMD_BIN=$2
            shift 2
            ;;
        --ffmpeg)
            require_value "$@"
            FFMPEG_BIN=$2
            shift 2
            ;;
        --ncdump)
            require_value "$@"
            NCDUMP_BIN=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

shopt -s nullglob

if [[ -z "$STATE_FILE" ]]; then
    all_state_candidates=("$START_DIR"/*.vmd)
    state_candidates=()
    for candidate in "${all_state_candidates[@]}"; do
        case "$(basename "$candidate")" in
            *.bak.vmd|*.backup.vmd) ;;
            *) state_candidates+=("$candidate") ;;
        esac
    done
    [[ ${#state_candidates[@]} -eq 1 ]] || \
        die "Could not auto-detect one .vmd file; use --state FILE"
    STATE_FILE=${state_candidates[0]}
fi
STATE_FILE=$(make_absolute "$STATE_FILE")
[[ -f "$STATE_FILE" ]] || die "State file not found: $STATE_FILE"
STATE_DIR=$(cd "$(dirname "$STATE_FILE")" && pwd -P)

if [[ -z "$TRAJECTORY_FILE" ]]; then
    trajectory_candidates=("$STATE_DIR"/*.nc)
    [[ ${#trajectory_candidates[@]} -eq 1 ]] || \
        die "Could not auto-detect one .nc file; use --trajectory FILE"
    TRAJECTORY_FILE=${trajectory_candidates[0]}
fi
TRAJECTORY_FILE=$(make_absolute "$TRAJECTORY_FILE")
[[ -f "$TRAJECTORY_FILE" ]] || die "Trajectory file not found: $TRAJECTORY_FILE"

TCL_FILE=$(make_absolute "$TCL_FILE")
[[ -f "$TCL_FILE" ]] || die "Tcl script not found: $TCL_FILE"

STATE_NAME=$(basename "$STATE_FILE")
STATE_STEM=${STATE_NAME%.*}
DURATION_LABEL=${DURATION_SECONDS//./p}

if [[ -z "$OUTPUT_FILE" ]]; then
    if [[ -n "$SAMPLE_COUNT" ]]; then
        OUTPUT_FILE="data/processed/${STATE_STEM}_md_${SAMPLE_COUNT}frames.gif"
    else
        OUTPUT_FILE="data/processed/${STATE_STEM}_md_${DURATION_LABEL}s.gif"
    fi
fi
if [[ -z "$FRAMES_DIR" ]]; then
    FRAMES_DIR="data/processed/${STATE_STEM}_md_frames"
fi
if [[ -z "$LOG_FILE" ]]; then
    LOG_FILE="data/processed/${STATE_STEM}_render.log"
fi

OUTPUT_FILE=$(make_absolute "$OUTPUT_FILE")
FRAMES_DIR=$(make_absolute "$FRAMES_DIR")
LOG_FILE=$(make_absolute "$LOG_FILE")

[[ "$DURATION_SECONDS" =~ ^[0-9]+([.][0-9]+)?$ ]] || die "Invalid duration: $DURATION_SECONDS"
[[ "$FPS" =~ ^[0-9]+([.][0-9]+)?$ ]] || die "Invalid fps: $FPS"
awk -v value="$DURATION_SECONDS" 'BEGIN {exit !(value > 0)}' || die "Duration must be positive"
awk -v value="$FPS" 'BEGIN {exit !(value > 0)}' || die "FPS must be positive"

[[ "$WIDTH" =~ ^[0-9]+$ ]] && (( WIDTH > 0 )) || die "Width must be a positive integer"
[[ "$HEIGHT" =~ ^[0-9]+$ ]] && (( HEIGHT > 0 )) || die "Height must be a positive integer"
[[ "$SMOOTH_RADIUS" =~ ^[0-9]+$ ]] || die "Smooth radius must be a non-negative integer"

if [[ -z "$SAMPLE_COUNT" ]]; then
    SAMPLE_COUNT=$(awk -v duration="$DURATION_SECONDS" -v fps="$FPS" \
        'BEGIN {printf "%d", int(duration * fps + 0.5)}')
fi
[[ "$SAMPLE_COUNT" =~ ^[0-9]+$ ]] && (( SAMPLE_COUNT >= 2 )) || \
    die "Sample count must be an integer of at least 2"
EFFECTIVE_DURATION=$(awk -v samples="$SAMPLE_COUNT" -v fps="$FPS" \
    'BEGIN {printf "%.6g", samples / fps}')

if [[ -z "$VMD_BIN" ]]; then
    VMD_BIN=$(command -v vmd || true)
fi
if [[ -z "$VMD_BIN" ]]; then
    vmd_candidates=(/Applications/VMD*.app/Contents/Resources/VMD.app/Contents/MacOS/VMD)
    for candidate in "${vmd_candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            VMD_BIN=$candidate
            break
        fi
    done
fi
[[ -n "$VMD_BIN" && -x "$VMD_BIN" ]] || \
    die "VMD executable not found; use --vmd FILE or set VMD_BIN"

if [[ -z "$FFMPEG_BIN" ]]; then
    FFMPEG_BIN=$(command -v ffmpeg || true)
fi
[[ -n "$FFMPEG_BIN" && -x "$FFMPEG_BIN" ]] || \
    die "ffmpeg executable not found; use --ffmpeg FILE or set FFMPEG_BIN"

if [[ -z "$TOTAL_FRAMES" ]]; then
    if [[ -z "$NCDUMP_BIN" ]]; then
        NCDUMP_BIN=$(command -v ncdump || true)
    fi
    [[ -n "$NCDUMP_BIN" && -x "$NCDUMP_BIN" ]] || \
        die "ncdump not found; install it or provide --total-frames COUNT"

    NETCDF_HEADER=$("$NCDUMP_BIN" -h "$TRAJECTORY_FILE")
    TOTAL_FRAMES=$(printf '%s\n' "$NETCDF_HEADER" | \
        sed -nE '/^[[:space:]]*frame[[:space:]]*=/s/.*\(([0-9]+) currently\).*/\1/p' | \
        head -n 1)
    if [[ -z "$TOTAL_FRAMES" ]]; then
        TOTAL_FRAMES=$(printf '%s\n' "$NETCDF_HEADER" | \
            sed -nE 's/^[[:space:]]*frame[[:space:]]*=[[:space:]]*([0-9]+)[[:space:]]*;.*/\1/p' | \
            head -n 1)
    fi
fi

[[ "$TOTAL_FRAMES" =~ ^[0-9]+$ ]] && (( TOTAL_FRAMES >= 2 )) || \
    die "Could not determine a valid NetCDF frame count; use --total-frames COUNT"
SOURCE_LAST_FRAME=$((TOTAL_FRAMES - 1))

mkdir -p "$FRAMES_DIR" "$(dirname "$OUTPUT_FILE")" "$(dirname "$LOG_FILE")"

printf 'VMD state:       %s\n' "$STATE_FILE"
printf 'Trajectory:      %s\n' "$TRAJECTORY_FILE"
printf 'Source frames:   %s\n' "$TOTAL_FRAMES"
printf 'Rendered frames: %s\n' "$SAMPLE_COUNT"
printf 'GIF timing:      %s fps, approximately %s seconds\n' "$FPS" "$EFFECTIVE_DURATION"
printf 'Image size:      %sx%s\n' "$WIDTH" "$HEIGHT"
if [[ -n "$ALIGN_SELECTION" ]]; then
    printf 'Alignment:       %s -> Top frame 0; transform all atoms\n' "$ALIGN_SELECTION"
else
    printf 'Alignment:       disabled\n'
fi
printf 'Frames directory:%s\n' " $FRAMES_DIR"
printf 'Output GIF:      %s\n' "$OUTPUT_FILE"

VMD_ARGS=(
    -dispdev text
    -size "$WIDTH" "$HEIGHT"
    -eofexit
    -e "$TCL_FILE"
    -args
    "$FRAMES_DIR"
    "$SAMPLE_COUNT"
    "$SAMPLE_COUNT"
    "$STATE_FILE"
    "$TRAJECTORY_FILE"
    "$SOURCE_LAST_FRAME"
    "$ALIGN_SELECTION"
    "$SMOOTH_RADIUS"
    "$WIDTH"
    "$HEIGHT"
)

set +e
(
    cd "$STATE_DIR"
    "$VMD_BIN" "${VMD_ARGS[@]}"
) 2>&1 | tr '\r' '\n' | tee "$LOG_FILE" | awk -v last_sample="$((SAMPLE_COUNT - 1))" '
    /^RENDER_FRAME/ {
        if (match($0, /sample=[0-9]+/)) {
            sample_index = substr($0, RSTART + 7, RLENGTH - 7) + 0
            if (sample_index % 10 == 0 || sample_index == last_sample) {
                print
                fflush()
            }
        }
        next
    }
    /^ERROR\)/ {
        if (!seen_error[$0]++) {
            print
            fflush()
        }
        next
    }
    /^(STATE_|ALIGN_|OUTPUT_|AXES_|RENDER_SETUP|RENDER_COMPLETE|Info\) Exiting)/ {
        print
        fflush()
    }
'
PIPE_RESULTS=("${PIPESTATUS[@]}")
set -e

VMD_STATUS=${PIPE_RESULTS[0]}
(( VMD_STATUS == 0 )) || die "VMD failed with exit status $VMD_STATUS; see $LOG_FILE"
grep -Fq "RENDER_COMPLETE rendered=$SAMPLE_COUNT" "$LOG_FILE" || \
    die "VMD did not report successful completion; see $LOG_FILE"

MISSING_COUNT=0
for ((frame_index = 0; frame_index < SAMPLE_COUNT; frame_index++)); do
    printf -v frame_file '%s/frame_%04d.tga' "$FRAMES_DIR" "$frame_index"
    if [[ ! -s "$frame_file" ]]; then
        if (( MISSING_COUNT < 10 )); then
            printf 'Missing frame: %s\n' "$frame_file" >&2
        fi
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done
(( MISSING_COUNT == 0 )) || die "$MISSING_COUNT rendered frame files are missing"

GIF_FILTER="[0:v]crop=${WIDTH}:${HEIGHT}:(iw-${WIDTH})/2:(ih-${HEIGHT})/2,split[gifsrc][palettesrc];[palettesrc]palettegen=stats_mode=diff[palette];[gifsrc][palette]paletteuse=dither=sierra2_4a:diff_mode=rectangle"

"$FFMPEG_BIN" -hide_banner -y \
    -framerate "$FPS" \
    -start_number 0 \
    -i "$FRAMES_DIR/frame_%04d.tga" \
    -frames:v "$SAMPLE_COUNT" \
    -filter_complex "$GIF_FILTER" \
    -loop 0 \
    "$OUTPUT_FILE"

VERIFY_OUTPUT=$("$FFMPEG_BIN" -hide_banner -i "$OUTPUT_FILE" -map 0:v:0 -f null - 2>&1)
DECODED_FRAMES=$(printf '%s\n' "$VERIFY_OUTPUT" | tr '\r' '\n' | \
    sed -nE 's/^frame=[[:space:]]*([0-9]+).*/\1/p' | tail -n 1)
[[ "$DECODED_FRAMES" == "$SAMPLE_COUNT" ]] || \
    die "GIF verification decoded ${DECODED_FRAMES:-0} frames; expected $SAMPLE_COUNT"

GIF_DURATION=$(printf '%s\n' "$VERIFY_OUTPUT" | \
    sed -nE 's/.*Duration: ([0-9:.]+),.*/\1/p' | head -n 1)

printf '\nComplete.\n'
printf 'GIF:      %s\n' "$OUTPUT_FILE"
printf 'Duration: %s\n' "${GIF_DURATION:-unknown}"
printf 'Frames:   %s\n' "$DECODED_FRAMES"
printf 'Log:      %s\n' "$LOG_FILE"
