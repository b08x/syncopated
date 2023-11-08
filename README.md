# Ansible Collection: Syncopated

The "Syncopated" Ansible collection contains roles, playbooks, and modules to help configure and manage Linux hosts that are part of an audio production workflow. This includes digital signal processing (DSP) servers as well as digital audio workstation (DAW) client machines.

The main features of the collection are:

audio-dsp role - Configures Linux servers for real-time DSP workloads. Tunes the kernel, installs DSP software packages, sets up low-latency audio interfaces, and optimizes system resources for reliable high-performance audio.

audio-workstation role - Prepares Linux workstations for use as DAWs. Installs audio production software like Ardour, Audacity, etc. Sets up user accounts, configures pulseaudio and JACK for pro audio, and optimizes settings for audio editing and mixing.

jackd module - Manages the JACK Audio Connection Kit daemon. Can install, configure, start, stop jackd across nodes.

pulseaudio module - Configures pulseaudio for low latency performance.

The collection aims to automate and simplify setting up the Linux infrastructure for professional audio production environments. It handles mundane system configuration to allow engineers to focus on their creative work. The consistent configurations aid collaboration between sound engineers when working across different
studios and facilities.



https://github.com/aplatform64/aplatform64

https://github.com/vvo/ansible-archee/blob/master/roles/base/vars/main.yml
