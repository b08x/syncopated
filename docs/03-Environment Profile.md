# Environment Profile

## global envrionment

* `/etc/profile` initializes variables for login shells _only_.


Templates that comprise a user profile are used in several roles.

## [bash](roles/bash/README.md)

```bash
├── .bash_logout
└── .bashrc
```

## [base](roles/base/README.md)
```markdown
[ base](roles/base/templates/etc/skel)
├── .aliases.j2
├── .config
│   └── environment.d
│       └── cachyos.conf.j2
└── .profile.j2
```

## [desktop](roles/desktop/README.md)
```
roles/desktop/templates/etc/skel
└── .config
    ├── dunst
    │   └── dunstrc.j2
    ├── picom
    │   └── picom.conf.j2
    ├── rofi
    │   ├── colors
    │   │   ├── adapta.rasi.j2
    │   │   ├── arc.rasi.j2
    │   │   ├── black.rasi.j2
    │   │   ├── catppuccin.rasi.j2
    │   │   ├── cyberpunk.rasi.j2
    │   │   ├── dracula.rasi.j2
    │   │   ├── everforest.rasi.j2
    │   │   ├── gruvbox.rasi.j2
    │   │   ├── lovelace.rasi.j2
    │   │   ├── navy.rasi.j2
    │   │   ├── nord.rasi.j2
    │   │   ├── onedark.rasi.j2
    │   │   ├── paper.rasi.j2
    │   │   ├── solarized.rasi.j2
    │   │   ├── tokyonight.rasi.j2
    │   │   └── yousai.rasi.j2
    │   ├── config.rasi.j2
    │   ├── file-browser
    │   ├── gruvbox-common.rasi.j2
    │   ├── gruvbox-dark-hard.rasi.j2
    │   ├── launchers
    │   │   ├── type-1
    │   │   │   ├── shared
    │   │   │   │   ├── colors.rasi.j2
    │   │   │   │   └── fonts.rasi.j2
    │   │   │   ├── style-10.rasi.j2
    │   │   │   └── style-8.rasi.j2
    │   │   └── type-4
    │   │       ├── launcher.sh.j2
    │   │       ├── shared
    │   │       │   ├── colors.rasi.j2
    │   │       │   └── fonts.rasi.j2
    │   │       └── style-6.rasi.j2
    │   └── scripts
    │       ├── launcher_main.sh.j2
    │       ├── launcher_t1.sh.j2
    │       └── launcher_t4.sh.j2
    ├── swhkd
    │   └── swhkdrc.j2
    └── sxhkd
        └── sxhkdrc.j2
```

## [i3](roles/i3/README.md)
```
roles/i3/templates/etc/skel
└── .config
    ├── dunst
    │   └── dunstrc.j2
    ├── i3
    │   ├── appearance.j2
    │   ├── autostart.j2
    │   ├── config.j2
    │   ├── keybindings.j2
    │   ├── modes
    │   │   └── resize.j2
    │   ├── window_assignments.j2
    │   └── window_behavior.j2
    ├── i3status-rust
    │   ├── config.toml.j2
    │   └── themes
    │       └── syncopated.toml.j2
    └── picom
        └── picom.conf.j2
```

## [terminal](roles/terminal/README.md)
```
roles/terminal/templates/etc/skel
└── .config
    ├── alacritty
    │   └── alacritty.yml.j2
    ├── htop
    │   └── htoprc.j2
    ├── kitty
    │   ├── cpu.conf.j2
    │   ├── current-theme.conf.j2
    │   ├── kitty.conf.j2
    │   ├── open-actions.conf.j2
    │   └── start.conf.j2
    └── lnav
        └── checklog.lnav.j2
```

## [theme](roles/theme/README.md)
```
roles/theme/templates/etc/skel
├── .config
│   ├── gtk-3.0
│   │   ├── bookmarks.j2
│   │   ├── gtk.css.j2
│   │   └── settings.ini.j2
│   ├── gtk-4.0
│   │   └── settings.ini.j2
│   ├── Kvantum
│   │   └── kvantum.kvconfig.j2
│   ├── qt5ct
│   │   ├── colors
│   │   │   └── syncopated.conf.j2
│   │   └── qt5ct.conf.j2
│   └── qt6ct
│       ├── colors
│       │   └── syncopated.conf.j2
│       └── qt6ct.conf.j2
└── .gtkrc-2.0.j2
```

## [xorg](roles/xorg/README.md)
```
roles/xorg/templates/etc/skel
├── .xinitrc.j2
├── .xprofile.j2
├── .Xresources.j2
└── .xserverrc.j2
```

## [zsh](roles/zsh/README.md)
```
roles/zsh/templates/etc/skel
├── .zprofile.j2
├── .zshenv.j2
└── .zshrc.j2
```
