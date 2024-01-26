# audio

The main tasks performed by the audio role include:

Installing required audio/codec packages (tag: packages)

Creating directories for audio configuration files (tag: audio)

Configuring real-time tuning settings like rtprio, niceness for audio group (tag: tuning, realtime)

Installing and configuring Tuned daemon for a real-time profile (tag: tuned)

Configuring RT priority and RTKIT tools (tag: rtkit, rtirq)

Configuring CPU power management using cpupower (tag: cpupower)

Disabling IRQ balancer service (tag: audio)

Configuring JackTrip autostart files (tag: jacktrip)

Adding support for MIDI tool LSMI (tag: lsmi, midi)

It handles all aspects of configuring the system, users and services for professional low-latency audio work.

Key files involved are:

roles/audio/tasks/tuning.yml
roles/audio/tasks/main.yml
roles/audio/defaults/main.yml
The role ensures the system meets real-time requirements for audio applications and protocols like JackTrip through configuring priorities, scheduling algorithms and services.