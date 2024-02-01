#!/usr/bin/env bash

qjackrcd -l -26 -r -dir ~/Recordings/audio/dictations \
--pcmd 'sox ${0} ${0%%wav}ogg' \
--jack-cns1 'Calf JACK Host:Deesser Out #1' \
--jack-cns2 'Calf JACK Host:Deesser Out #2'


/usr/bin/jack_capture -fp jack_capture_ -f wav -b 24 -c 1 -p 'x42-eq - Parametric Equalizer Mono:out' --daemon
