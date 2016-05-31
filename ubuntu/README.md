# Ubuntu Tips

## apt

Don't install recommended and suggested packages.

```
# apt -o APT::Install-Recommends="false" -o APT::Install-Suggests="false" install nmap
# apt --no-install-recommends install nmap
```

Don't prompt while installing package, the following is usually enough, run `dpkg --force-help` to see more if not enough.

```
# DEBIAN_FRONTEND=noninteractive apt -y --force-yes --allow-unauthenticated -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install keepalived
# dpkg --force-help
```

Ask dpkg to install configuration file if it is currently missing.

```
# apt -o Dpkg::Options::="--force-confmiss" install keepalived
```

## Things to do after install Ubuntu

### Install essential packages

```
$ sudo apt install account-plugin-irc bash-completion build-essential \
        chromium-browser command-not-found compizconfig-settings-manager curl \
        dns-utils git gnupg jq sshpass subversion tree vim whois
```


### Disable HUD

`System Settings` -- `Keyboard` -- `Shortcuts` -- `Launchers` -- `Key to show the HUD`


### Adjust screensaver timeout

`System Settings` -- `Brightness` -- `Turn screen of when inactive for 30 minutes`


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


### Change Terminal tabs

In Ubuntu 16.04, when open multiple tabs in the terminal window, the tabs have a bigger height. Using the following css will make the tabs more coordinating in Unity Desktop Environment.


```
$ mkdir -p ~/.config/gtk-3.0
$ vim ~/.config/gtk-3.0/gtk.css
```

Content: `~/.config/gtk-3.0/gtk.css`

```
TerminalWindow .button {
  /* Make the notebook tab have a smaller height */
  padding: 2px 0;
}

TerminalWindow .notebook {
  /* Make the notebook tab a little darker */
  padding: 0;
  background-color: #CCC;
}

TerminalWindow .notebook tab:active {
  /* Highlight the active tab */
  background-color: #EEE;
}
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


### Allow root login

```
$ sudo passwd -u root # or remove the `!` in /etc/shadow
$ sudo passwd root
$ sudo vim /etc/ssh/sshd_config
PermitRootLogin yes
```


### sudo without password

```
$ sudo vim /etc/sudoers
zhiwei  ALL=(ALL:ALL) NOPASSWD: ALL
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
$ sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
$ sudo echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
$ sudo apt-get update
$ sudo apt-get -y install google-chrome-stable chromium-browser
$ sudo vim /etc/chromium-browser/default
```

Put this line to this file:

```
CHROMIUM_FLAGS="--ppapi-flash-path=/opt/google/chrome/PepperFlash/libpepflashplayer.so --ppapi-flash-version=$PEPPER_FLASH_VERSION"
```

Link: <http://www.webupd8.org/2012/09/how-to-make-chromium-use-flash-player.html>


### Fcitx can't use in Java applications

Like IBM Notes, eclipse...

Create a file `~/.xprofile` with following content:

```
# export LC_ALL=zh_CN.utf8
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=xim
export GTK_IM_MODULE=xim
```


### Ubuntu screen recorder

```
$ sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
$ sudo apt-get update
$ sudo apt-get install simplescreenrecorder
```

Easy to use: <http://www.webupd8.org/2013/06/simplescreenrecorder-powerful-screen.html>


### Install Rime for IBus

```
$ sudo apt-get install ibus-rime librime-data-wubi librime-data-pinyin-simp
```

For details, check [rime](../rime/).


### Install package using proxy

```
$ sudo apt-get -o "Acquire::http::Proxy=http://10.10.10.104:8088" install tree
```

Reference: <https://help.ubuntu.com/community/AptGet/Howto#Setting_up_apt-get_to_use_a_http-proxy>


### Update system proxy via command line

```
$ gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
$ gsettings set org.gnome.system.proxy.socks port 1080
$ gsettings set org.gnome.system.proxy mode 'manual'
$ gsettings set org.gnome.system.proxy mode 'none'
```


## Issues

* Unable to find expected entry 'main/binary-i386/Packages'

    1. solution one

            # dpkg --print-architecture
            # dpkg --print-foreign-architectures
            # dpkg --remove-architecture i386

    2. solution two

        deb [ arch=amd64 ] http://dl.google.com/linux/chrome/deb/ stable main

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
