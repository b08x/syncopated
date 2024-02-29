#!/usr/bin/env bash
set -x

declare -rx timestamp=$(date +'%Y-%m-%d_%H-%M-%S')

declare -rx dictations="$HOME/Recordings/audio/dictations"

declare -rx capturefile="jack_capture_${timestamp}"

declare -rx wavfile="${capturefile}.wav"
declare -rx mp3file="/tmp/${capturefile}.mp3"

declare xel_args="-ib"

function cleanup() {
        cd /tmp && rm -rf *.mp3
}

function load_mic() {
  card=$(cat /proc/asound/cards|grep -E -m1 "PowerMic"|choose 0)
  jack_load 'handheld' zalsa_in -i "-d hw:${card},0"
}

function capture2mp3() {
        sox $dictations/${wavfile} ${mp3file}
}

function transcribe() {
        text=$(gum spin -s line --title "transcribing" --show-output -- curl https://api-inference.huggingface.co/models/distil-whisper/distil-large-v2 \
                        -X POST \
                        -H "Content-Type: multipart/form-data" \
                        -H "Authorization: Bearer $HUGGINGFACE_API_KEY" \
                        --data-binary "@${mp3file}")

        echo $text | jq '.text' | xargs -0 | ruby -pe 'gsub(/^\s/, "")'
}

#########################################################################
#                             Greetings                                 #
#########################################################################
trap cleanup SIGINT SIGTERM ERR EXIT

gum style \
        --foreground 014 --border-foreground 024 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        'Hello.' && sleep 1

xsel -cb

while true; do
        rm -rf $mp3file

        if ! [[ $(jack_lsp | grep handheld) ]]; then
          load_mic || notify-send -t 5000 -u critical  "mic not connected"
        fi

        if [[ $(jack_lsp | grep handheld) ]]; then
          jack_capture -f wav -b 24 -c 3 -p 'handheld:capture_1' -p 'system:capture_*' ${dictations}/${wavfile} && \
          sox ${dictations}/${wavfile} ${mp3file} remix 1-3
        else
          jack_capture -f wav -b 24 -c 2 -p 'system:capture_*' ${dictations}/${wavfile} && \
          sox ${dictations}/${wavfile} ${mp3file} remix 1-2
        fi

        if [ $? = 0 ]; then
          notify-send -t 5000 'transcribing....'
          logger -t dictation --priority user.debug transcribing ${dictations}/${wavfile}

          text=""
          max_retries=5

          for ((i=0; i<max_retries; i++)); do

            text=$(transcribe)
            if [[ "$text" != "null" ]]; then
                    break
            fi

						echo $text

            echo "Transcription failed, retrying ($((max_retries-i)))..."

						gum spin -s line --title "waiting 10 seconds..." sleep 10

          done

          if [[ "$text" == "null" ]]; then

            notify-send -t 5000 -u critical "Transcription failed"
          else
            text=$(echo $text | xargs -0 | ruby -pe 'gsub(/^\s/, "")')
            xsel -a -b <<< "$text"
            notify-send -t 10000 "transcription copied to clipboard"
            xsel -ob | gum format -t code
          fi

        else
          notify-send -t 5000 -u critical "capture failed"
        fi

        gum confirm "continue?"

        if [ $? = 1 ]; then
                echo "ok. exiting"
                # gum confirm "cleanup?" && cleanup
                gum spin --spinner dot --title "exiting in 5 seconds..." -- sleep 5
                exit
        fi

done
