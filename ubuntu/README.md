# Ubuntu Tips

## Things after install Ubuntu

### Install essential packages

```
$ sudo apt-get install vim git tree subversion gnupg sshpass nfs-common whois account-plugin-irc compizconfig-settings-manager
```

### Configure VIM

```
$ cd ~
$ mv .vim .vim.bak
$ git clone https://github.com/chenzhiwei/dot_vim .vim
$ ln -sf .vim/dot_vimrc .vimrc
```

### Font configure

```
$ sudo apt-get install fonts-wqy-zenhei fonts-wqy-microhei ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy
$ sudo vim /etc/fonts/conf.avail/69-language-selector-zh-cn.conf # remove test zh-cn block
```

```
<test name="lang">
    <string>zh-cn</string>
</test>
```

Download this [local fonts configure file](.fonts.conf) and put it to `~/.fonts.conf`.

After this try to use this command to verify:

```
$ ls ~/.fonts.conf && echo 'Fonts configured!'
```

### Disable HUD

`System Settings` -- `Keyboard` -- `Shortcuts` -- `Launchers` -- `Key to show the HUD`

### Adjust screensaver timeout

`System Settings` -- `Brightness` -- `Turn screen of when inactive for 30 minutes`

### Disable online search result

`System Settings` -- `Security & Privacy` -- `Search`

### Disable Super key

Open ccsm, then

`Ubuntu Unity Plugin` -- `General` -- `Key to show the menu bar` -- `disable`

`Ubuntu Unity Plugin` -- `Launcher` -- `Key to show the Dash` -- `disable`

### Disable Guest/Remote Login

```
$ sudo vim /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
[SeatDefaults]
allow-guest=false
```

### Change Terminal border and tab

I don't like the terminal border when open multiple tabs.

```
$ mkdir -p ~/.config/gtk-3.0
$ vim ~/.config/gtk-3.0/gtk.css
```

Content: `~/.config/gtk-3.0/gtk.css`

```
@define-color normal #CCC;
@define-color active #EEE;
@define-color background #999;

TerminalWindow.background {
    /* Top tab bar background*/
    background-color: shade(@background, 1);
}

TerminalWindow .notebook {
    border: 0;
    border-radius: 0;
    padding: 3px 0 0 0;
    background-color: shade(@active, 1);
}

TerminalWindow .notebook tab:active {
    background-color: shade(@active, 1);
}

TerminalWindow .notebook tab {
    border-top-left-radius: 5px;
    border-top-right-radius: 5px;
    padding: 0 3px;
    background-color: shade(@normal, 1);
}

/* reference: /usr/share/themes/Ambiance/gtk-3.0/apps/gnome-terminal.css */
```

URL: <http://askubuntu.com/questions/221291/remove-ugly-fat-bazel-from-gnome-terminal-with-multiple-tabs>

### Use Bluetooth Transfer File

There will be errors like `GDbus.Error:org.openobex.Error.Failed: Unable to request session`, so you need to run `bluez-simple-agent` command in terminal before you transfer files.

### Use OpenVPN on Ubuntu

```
$ sudo apt-get install openvpn network-manager-openvpn \
        network-manager-openvpn-gnome network-manager-vpnc \
        network-manager-vpnc-gnome
```

### Change locale

```
$ locale
$ sudo vim /etc/default/locale
LANG=en_US.UTF-8
LANGUAGE=en_US:en
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC=en_US.UTF-8
LC_TIME=en_US.UTF-8
$ sudo locale-gen
```

If you encounter warning when run `locale` command like this `locale: Cannot set LC_CTYPE to default locale: No such file or directory`, this means you did not generate en_US.UTF-8. Simply run `sudo locale-gen en_US.UTF-8` to solve this issue.

URL: <https://help.ubuntu.com/community/Locale>

### Edit the sound menu on the top panel

```
$ gsettings get com.canonical.indicator.sound interested-media-players
['rhythmbox', 'deepin-music-player']
$ gsettings set com.canonical.indicator.sound interested-media-players "['deepin-music-player']"
```

### Ubuntu Crontab GUI Application

It is possible to run gui applications via cronjobs. This can be done by telling cron which display to use.

```
* * * * * user env DISPLAY=:0 gui_appname
```

The `env DISPLAY=:0` portion will tell cron to use the current display (desktop) for the program "gui_appname".

Link: <https://help.ubuntu.com/community/CronHowto>

### Use Chrome PepperFlash in Chromium

Install Google Chrome

```
$ sudo vim /etc/apt/sources.list.d/google-chrome-unstable.list
deb http://dl.google.com/linux/chrome/deb/ stable main
$ sudo apt-get update
$ sudo apt-get install google-chrome-stable chromium-browser
$ sudo vim /etc/chromium-browser/default
```

Put this line to this file:

```
CHROMIUM_FLAGS="--ppapi-flash-path=/opt/google/chrome/PepperFlash/libpepflashplayer.so --ppapi-flash-version=$PEPPER_FLASH_VERSION"
```

Link: <http://www.webupd8.org/2012/09/how-to-make-chromium-use-flash-player.html>

### Install Google Earth

```
$ wget http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
$ sudo dpkg -i google-earth-stable_current_amd64.deb
$ sudo apt-get -f install
```

Link: <http://askubuntu.com/questions/302135/google-earth-on-13-04-ubuntu>

### Ibus Wubi Table can't input phrase

1.Open Ibus Preference

2.Select General

3.Font and Style, set Show language panel to `When active` or `Always`

4.Then, when you switch to ibus, it will show the language panel, so you can set what you want.

### Ubuntu screen recorder

```
$ sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
$ sudo apt-get update
$ sudo apt-get install simplescreenrecorder
```

Easy to use: <http://www.webupd8.org/2013/06/simplescreenrecorder-powerful-screen.html>

### Install fcitx input method

```
$ sudo add-apt-repository ppa:fcitx-team/nightly
$ sudo apt-get update
$ sudo apt-get install fcitx-sogoupinyin fcitx-table-wubi
```

### Install Deepin Screenshot

```
$ sudo add-apt-repository ppa:chenzhiwei/ppa
$ sudo apt-get update
$ sudo apt-get install python-deepin-gsettings indicator-screenshot
$ mkdir -p ~/.config/autostart
$ cp /usr/share/indicator-screenshot/indicator-screenshot.desktop ~/.config/autostart
```

### Install package using proxy

```
$ sudo apt-get -o "Acquire::http::Proxy=http://10.10.10.104:8088" install tree
```

Reference: <https://help.ubuntu.com/community/AptGet/Howto#Setting_up_apt-get_to_use_a_http-proxy>

## Create VM for Windows

```
# mkdir /var/instances/windows
# cd /var/instances/windows
# qemu-img create windows.img 10G
# kvm -no-acpi -m 750 -cdrom ~/windows_xp_install.iso -boot d windows.img
```

OR

```
# apt-get install python-virtinst
# virt-install --connect qemu:///system -n winxp -r 512 -f windows.img \
    -s 12 -c windowsxpsp2.iso --vnc --noautoconsole --os-type windows \
    --os-variant winxp --network=br0
```

Link: <http://ubuntuforums.org/showthread.php?t=970385>

## Build Debian package and upload to Ubuntu PPA

```
$ sudo apt-get install devscripts dput gnupg debhelper
$ gpg --import gpg_public_key/gpg_secret_key
$ gpg --list-keys
$ git clone https://github.com/chenzhiwei/indicator-screenshot
$ cd indicator-screenshot
$ debuild -S -k98564809
$ dput ppa:chenzhiwei/ppa indicator-screenshot_0.0.2.saucy.1-1ubuntu1_source.changes
```
