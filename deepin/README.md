# Deepin

## Configure apt

```
sudo echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99zhiwei-custom
```

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
apt install -y ibus ibus-qt1 ibus-qt4 ibus-clutter ibus-gtk ibus-gtk3 ibus-rime librime-data-wubi librime-data-pinyin-simp librime-data-stroke
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

## HiDPI high screen resolution

QT does not support HiDPI until 5.6, so need to add an environment variable before starting the QT applications.

Such as `QT_SCALE_FACTOR=2 your-app`, or `QT_AUTO_SCREEN_SCALE_FACTOR=1 your-app`.

In .desktop file, add `Exec=env QT_AUTO_SCREEN_SCALE_FACTOR=1 your-app`.

GTK HiDPI, export `GDK_SCALE=2`, then start the application.
