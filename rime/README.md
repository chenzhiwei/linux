# Rime Input Method Engine

First of all, I love Rime.

## Install Rime for IBus

```
$ sudo apt-get install ibus-rime librime-data-wubi librime-data-pinyin-simp
```

## Configure Rime

```
$ cp default.custom.yaml wubi86.custom.yaml ~/.config/ibus/rime
```

## Restart Rime

```
$ rm -f ~/.config/ibus/rime/default.yaml
$ ibus-daemon -xdr
```

## Rime on MacOS

```
brew cask install squirrel

git clone https://github.com/rime/rime-pinyin-simp
git clone https://github.com/rime/rime-wubi

cp -r *.yaml rime-pinyin-simp/*.yaml rime-wubi/*.yaml ~/Library/Rime/
```
