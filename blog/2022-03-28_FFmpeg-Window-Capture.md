# FFmpeg Window Capture

If you've read the FFmpeg website's
[Capture/Desktop](https://trac.ffmpeg.org/wiki/Capture/Desktop) page
or another similar tutorial about screen recording, you may have learned
that the `x11grab` device can be used to capture a specific region of your
screen, but did you know that you can also record a window by it's ID just
like OBS does?

First, you'll need to find the ID of the window that you want to capture
with `xwininfo`:

  <center>
    <video height="100%" width="700vmin" autoplay loop>
      <source src="/media/xwininfo.mp4" type="video/mp4" />
    </video>
  </center>

Now we can use the `-window_id` parameter of the `x11grab` device with
FFmpeg to capture the window.  Here's an example of a "nearly lossless"
MP4 capture at 60 frames per second with a constant quality of `10`:
```bash
ffmpeg -f x11grab -thread_queue_size 4096 -framerate 60 -window_id 0x940000a \
  -c:v libx264 -crf 10 output.mp4
```

### Recording With NVENC

If you're using an NVIDIA card with proprietary drivers, you can encode with
NVENC:
```bash
ffmpeg -f x11grab -thread_queue_size 4096 -framerate 60 -window_id 0x940000a \
  -c:v hevc_nvenc -preset slow -tune hq -tier high -cq 10 output.mp4
```

## Recording Desktop Audio

If you'd like to record desktop audio with Pulse or PipeWire, you can find
the name of your audio card with `pactl` (line-wrapped to 80 columns):
```
$ pactl list short | grep monitor
75      alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QUZ0C9981932-00.analog-ster
eo.monitor        PipeWire        s32le 2ch 48000Hz       RUNNING
77      alsa_output.pci-0000_2d_00.1.hdmi-stereo-extra2.monitor PipeWi
e        s32le 2ch 48000Hz RUNNING
79      alsa_output.usb-C-Media_Electronics_Inc._USB_Multimedia_Audio_Device-00.
analog-stereo.monitor     PipeWire        s16le 2ch 48000Hz       RUNNING
81      alsa_output.pci-0000_2f_00.4.iec958-stereo.monitor      PipeWire        
s32le 2ch 48000Hz RUNNING
212     easyeffects_sink.monitor        PipeWire        float32le 2ch 48000Hz   
RUNNING
448     alsa_output.usb-SmartAction_FiiO_USB_Audio_Class_2.0_DAC_0007-00.analog-
stereo.monitor    PipeWire        s32le 2ch 48000Hz       RUNNING
858     soundux_sink.monitor    PipeWire        float32le 2ch 48000Hz   RUNNING
```

You can then record audio and video together with FFmpeg like so:
```bash
ffmpeg -f x11grab -thread_queue_size 4096 -framerate 60 -window_id 0x940000a \
  -f pulse -thread_queue_size 8192 -ac 2 \
  -i alsa_output.usb-SmartAction_FiiO_USB_Audio_Class_2.0_DAC_0007-00.analog-stereo.monitor \
  -c:a aac -b:a 256k \
  -c:v libx264 -crf 10 output.mp4
```

## Putting It All Together in a Script

Below is a script that automates this somewhat.  Note that you will
need to edit the `audio_device` variable for the `-a` flag to work.  You may
also want to edit the `recording_dir` as well.
```bash
#!/usr/bin/env bash

recording_dir='.'
date=$(date +%Y-%m-%d_%s)
show_cursor=0
show_region=0
record_audio=0
use_nvenc=0
prefix=""
audio_device=''

read -d '' usage <<EOF
USAGE
  window-capture [OPTIONS]

OPTIONS
  -h  Show this help.
  -a  Capture audio.  Make sure you modify the "audio_device" in the script!
  -n  Encode with NVENC.
  -c  Capture X cursor (disabled by default).
  -s  Show capture region.
  -p  Filename prefix (override default from window title).
  -d  Capture directory (override "$recording_dir").
EOF

chomp(){ sed 's/^\s\+//' | sed 's/\s\+$//' ; }

while getopts ':hcsp:d:an' opt; do
  case ${opt} in
    h)
      cat <<<"$usage"
      exit 0
      ;;
    c)
      show_cursor=1
      ;;
    s)
      show_region=1
      ;;
    p)
      prefix="$OPTARG"
      ;;
    d)
      recording_dir="$OPTARG"
      ;;
    a)
      [ -z "$audio_device" ] \
        && echo 'ERROR: Set "audio_device" first!' \
        && exit 1
      record_audio=1
      ;;
    n)
      use_nvenc=1
      ;;
    *)
      cat <<<"$usage"
      exit 1
      ;;
  esac
done

window_info=$(xwininfo)
winid_line=$(grep '^xwininfo:\s\+[wW]indow\s\+[iI][dD]:\s\+' <<<"$window_info")
window_id=$(awk '{print $4}' <<<"$winid_line")
if [ -z "$prefix" ]; then
  prefix=$( \
    sed 's/^xwininfo:\s\+[wW]indow\s\+[iI][dD]:\s\+[0-9xXa-fA-F\]\+\s\+"\(.*\)"\s*$/\1/' \
      <<<"$winid_line" \
    | sed 's/\s/_/g' | sed 's/\~/home/g' | sed 's/\//-/g' | sed 's/@/_/g' | chomp)
fi

if [ $record_audio -eq 1 ]; then
  audio_opts="-f pulse -thread_queue_size 8192 -ac 2 -i $audio_device -c:a aac -b:a 256k"
else
  audio_opts="-an"
fi

if [ $use_nvenc -eq 1 ]; then
  enc_opts='-c:v hevc_nvenc -preset slow -tune hq -tier high -cq 10'
else
  enc_opts='-c:v libx265 -crf 10'
fi

ffmpeg \
  -f x11grab -thread_queue_size 8192 -framerate 60 -window_id $window_id \
  -show_region $show_region -draw_mouse $show_cursor -i :0.0 \
  $audio_opts \
  $enc_opts \
  "$recording_dir/$prefix"_"$date.mkv" \
;
```

[DOWNLOAD](/blob/window-capture)
