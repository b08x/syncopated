# pi

Okay, so this rule is to manage various Raspberry Pi related tasks. One of the Pies has an RE speaker for micro-ray attached to it that needs to have the kernel modules installed.
right now it installs well with the Raspberry Pi 3 and like to try to see if we can get that working with the 4.


Oh, it also means to compile, build, jack trip.
Right at this moment 2.3.0 is not performing well in the tests.
So maybe go back to 2.0.2


-----


https://wiki.seeedstudio.com/ReSpeaker_4_Mic_Array_for_Raspberry_Pi/

https://github.com/jacktrip/jacktrip.git


https://github.com/radiganm/njconnect


sudo rfkill block wifi

sudo apt-get install libfftw3-dev libconfig-dev libasound2-dev libgconf-2-4
sudo apt-get install portaudio19-dev libatlas-base-dev

sudo apt-get install        python3 python3-dev python3-setuptools python3-pip python3-venv        git build-essential libatlas-base-dev swig portaudio19-dev        supervisor mosquitto sox alsa-utils libgfortran4 libopenblas-dev        espeak flite        perl curl patchelf ca-certificates

sudo apt-get -y install libasound2-dev libspeexdsp-dev



sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates

curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt -y install gcc g++ make
sudo apt -y install nodejs




153  git clone https://github.com/voice-engine/ec.git
  pip3 install pyaudio
  pip3 install pvrespeakerdemo
  picovoice_respeaker_demo
  ll
  ls
  pip3 install pvrespeakerdemo
  export PATH="$HOME/.local/bin:$PATH"


install jackd2


---


bcm2835-i2s 3f203000.i2s: I2S SYNC error!
