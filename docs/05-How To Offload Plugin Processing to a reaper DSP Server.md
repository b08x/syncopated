
```bash
+------------------+                     +------------+
|                  |                     |            |
|  workstation-01  |                     |reaperDSP-01|
|                  |                     |            |
|                  +-------------------->|            |
|                  |                     |            |
|                  |                     |            |
|                  |                     |            |
|                  |<--------------------+            |
|                  |                     +------------+
|                  |
+------------------+
```



designate a host in your environment, run the playbook `reaperDSP.yml` which configures the host device with a minimal profile to run reaper, jack and compatible plugins

































### system specs

```shell

# reaperDSP-01

The system is a custom desktop running ArchLabs Linux with a 64-bit architecture and a Zen kernel version 6.6.9-zen1-1-zen. It features an Intel 12th Gen Core i9-12900HK processor with 14 cores and 20 threads. The desktop environment is i3, and the system uses startx as the display manager.

The CPU operates with a base/boost speed of 4257/8500 MHz, and it utilizes Intel P-State scaling with a powersave governor. The graphics are handled by Intel Iris Xe Graphics with active ports including DP-2.

The system has multiple network interfaces, including Intel Alder Lake-P PCH CNVi WiFi, Intel Ethernet I225-V, and Realtek RTL8111/8168/8411 PCI Express Gigabit Ethernet. Bluetooth functionality is provided by an Intel AX211 Bluetooth module.

The primary audio device is the Intel Alder Lake PCH-P High Definition Audio, managed by the `snd_hda_intel` kernel driver. It operates on bus 00:1f.3 with chip-ID 8086:51c8. The system utilizes ALSA (Advanced Linux Sound Architecture) with kernel version 6.6.9-zen1-1-zen.

Additionally, the system has two audio servers running concurrently:

1. JACK (version 1.9.22) is active and managed by the root user and processes. It is used in conjunction with a2jmidid, which is also active. JACK provides tools like jack_control and jack_mixer.
    
2. PulseAudio (version 16.1) is also active and managed by the root user and processes. It is configured with various modules, including pulseaudio-alsa and pulseaudio-jack. Tools associated with PulseAudio include pacat, pactl, pamixer, pavucontrol, and pulsemixer.

```

```shell

# workstation-01

The system is a Lenovo ThinkPad X1 Yoga 3rd convertible system running Arch Linux with a 6.6.9-arch1-1 kernel. It features an Intel Core i7-8650U processor with four cores and eight threads, clocked between 400 and 4200 MHz. The system has 16 GB of RAM and a 953.87 GB Samsung SSD.

For graphics, it utilizes Intel UHD Graphics 620, supporting a 2560x2520 resolution on a Dell U2718Q monitor and a 1920x1080 resolution on an AU Optronics display.

The CPU operates at a base/boost speed of 1900/2100 MHz, with a governor set to powersave. The overall system utilizes advanced technologies like AVX, AVX2, and others, with various vulnerability mitigations in place.

Audio is managed by Intel Sunrise Point-LP HD Audio, and additional audio devices include the Lenovo ThinkPad Thunderbolt 3 Dock Audio and Dictaphone PowerMicII-NS. The system uses ALSA for audio, and there are two audio servers, JACK and PulseAudio, running concurrently.

```


For comparison, a proprietary solution that 