
```bash
TASK [user : Create systemd drop-in file for virtual console autologin] *****************************************************************************************************
--- before: /etc/systemd/system/getty@tty1.service.d/autologin.conf
+++ after: /tmp/ansible-local-166163vxt9666/tmpkrp016w2/autologin.conf.j2
@@ -1,5 +1,4 @@
 [Service]
+Environment=XDG_SESSION_TYPE=x11
 ExecStart=
-ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin b08x %I $TERM
-Type=simple
-Environment=XDG_SESSION_TYPE=x11
+ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin b08x - $TERM

changed: [tinybot]

```



```bash
changed: [soundbot] => (item=.xinitrc)
ok: [tinybot] => (item=.xprofile)
ok: [tinybot] => (item=.xserverrc)
ok: [tinybot] => (item=.Xresources)
--- before: /home/b08x/.xprofile
+++ after: /tmp/ansible-local-29171cmmck9hw/tmpt3lq6xfk/.xprofile.j2
@@ -32,11 +32,5 @@
 
 bash ~/.screenlayout/soundbot.sh
 
+
 [[ -f "$HOME/.asound.state" ]] && alsactl restore -f "$HOME/.asound.state"
-
-# wanting to have keyrings unlocked at login??? trying this out in xprofile:
-eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets,ssh)
-
-systemctl --user import-environment GPG_TTY SSH_AUTH_SOCK
-
-dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

changed: [soundbot] => (item=.xprofile)
```