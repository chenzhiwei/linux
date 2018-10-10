# Ubuntu

## Configure apt

Don't install recommended and suggested packages.

```
vi /etc/apt/apt.conf.d/99zhiwei-custom
APT::Install-Suggests "false";
APT::Install-Recommends "false";
```

or

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

**NOTE:** APT tools do not support `all_proxy` environment variable, you need to specify `http_proxy`, `https_proxy` and `ftp_proxy` to use them behind proxy.

## Install Chrome browser

```
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt update
apt install -y google-chrome-stable
```


## Install essential packages

```
apt update
apt install -y bash-completion build-essential command-not-found dnsutils git gnupg jq sshpass tree vim whois
apt install -y ibus-qt4 ibus-clutter ibus-rime librime-data-wubi librime-data-pinyin-simp
```

## Setup keyboard


```
xmodmap -e "keycode 76 = Insert Insert" # need persist this map from f10 to insert key
echo "keycode  76 = Insert Insert Insert Insert" >> ~/.xmodmaprc

echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode
echo 1 | sudo tee /sys/module/hid_apple/parameters/swap_opt_cmd

echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
echo options hid_apple swap_opt_cmd=1 | sudo tee -a /etc/modprobe.d/hid_apple.conf

sudo update-initramfs -u -k all
```

for xmodmap change, add a startup application with a shell wrapper of the `xmodmap` command.

## Disable Super_Key to show Gnome activities

```
gsettings set org.gnome.mutter overlay-key ""

gsettings set org.gnome.mutter overlay-key Super_L
```

## 中文字体问题

最明显的一个字是`门`字，会显示的特别奇怪，原因就是中文字体太靠后了，优先显示了日文。原因就是这个配置文件：`/etc/fonts/conf.d/64-language-selector-prefer.conf`，修改一下字体顺序就行了。在`.config/fontconfig/fonts.conf`里面修改正确就行了。

```
<fontconfig>
	<alias>
		<family>sans-serif</family>
		<prefer>
			<family>Noto Sans CJK SC</family>
			<family>Noto Sans CJK TC</family>
			<family>Noto Sans CJK KR</family>
			<family>Noto Sans CJK JP</family>
		</prefer>
	</alias>
	<alias>
		<family>serif</family>
		<prefer>
			<family>Noto Serif CJK SC</family>
			<family>Noto Serif CJK TC</family>
			<family>Noto Serif CJK KR</family>
			<family>Noto Serif CJK JP</family>
		</prefer>
	</alias>
	<alias>
		<family>monospace</family>
		<prefer>
			<family>Noto Sans Mono CJK SC</family>
			<family>Noto Sans Mono CJK TC</family>
			<family>Noto Sans Mono CJK KR</family>
			<family>Noto Sans Mono CJK JP</family>
		</prefer>
	</alias>
</fontconfig>
```


## Allow root login

```
$ sudo passwd -u root # or remove the `!` in /etc/shadow
$ sudo passwd root
$ sudo vim /etc/ssh/sshd_config
PermitRootLogin yes
```


## sudo without password

```
$ sudo vim /etc/sudoers
zhiwei  ALL=(ALL:ALL) NOPASSWD: ALL
```

## Check current display server(x11 or wayland)

```
loginctl
loginctl show-session <SESSION_ID> -p Type

loginctl show-session "$XDG_SESSION_ID" -p Type
```

## HiDPI high screen resolution

QT does not support HiDPI until 5.6, so need to add an environment variable before starting the QT applications.

Such as `QT_SCALE_FACTOR=2 your-app`, or `QT_AUTO_SCREEN_SCALE_FACTOR=1 your-app`.

In .desktop file, add `Exec=env QT_AUTO_SCREEN_SCALE_FACTOR=1 your-app`.

GTK HiDPI, export `GDK_SCALE=2`, then start the application.

## Change locale

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



## Ubuntu Crontab GUI Application

It is possible to run gui applications via cronjobs. This can be done by telling cron which display to use.

```
* * * * * user env DISPLAY=:0 gui_appname
```

The `env DISPLAY=:0` portion will tell cron to use the current display (desktop) for the program "gui_appname".

Link: <https://help.ubuntu.com/community/CronHowto>


## Use Chrome PepperFlash in Chromium


```
vim /etc/chromium-browser/default
CHROMIUM_FLAGS="--ppapi-flash-path=/opt/google/chrome/PepperFlash/libpepflashplayer.so --ppapi-flash-version=$PEPPER_FLASH_VERSION"
```

Link: <http://www.webupd8.org/2012/09/how-to-make-chromium-use-flash-player.html>


## Fcitx can't use in Java applications

Like IBM Notes, eclipse...

Create a file `~/.xprofile` with following content:

```
# export LC_ALL=zh_CN.utf8
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=xim
export GTK_IM_MODULE=xim
```


## Ubuntu screen recorder

```
$ sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
$ sudo apt-get update
$ sudo apt-get install simplescreenrecorder
```

Easy to use: <http://www.webupd8.org/2013/06/simplescreenrecorder-powerful-screen.html>


## Install Rime for IBus

```
$ sudo apt-get install ibus-rime librime-data-wubi librime-data-pinyin-simp
```

For details, check [rime](../rime/).


## Install package using proxy

```
$ sudo apt-get -o "Acquire::http::Proxy=http://10.10.10.104:8088" install tree
```

Reference: <https://help.ubuntu.com/community/AptGet/Howto#Setting_up_apt-get_to_use_a_http-proxy>


## Update system proxy via command line

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
