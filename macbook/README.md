# MacBook quick start

We now use MacBook Pro as workstation, following are some tips.

## Install iTerm

Make the `Dark Blue` color readable in iTerm with black/dark background.

```
iTerm --> Preferences --> Profiles --> Default --> Colors --> ANSI Colors --> Blue[Normal] --> click and change to a better color.
```

## Setup proxy

Install your proxy client and connect to your server.

Following is `curl` proxy, many commands like `brew` use `curl` to fetch contents.

```
$ export ALL_PROXY=socks5://127.0.0.1:1080
```

## Install Homebrew

```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Install packages

```
$ brew install bash-completion coreutils git git-review gnupg gnu-sed nmap tree wget
$ brew tap brona/iproute2mac
$ brew install iproute2mac
$ brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```

## Setup ~/.bash_profile

```
## Terminal labal and title
# PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
PS1='\u@\h:\w\$ '
PS1="\[\e]0;\u@\h: \w\a\]$PS1"

## Bash completion
. /usr/local/etc/bash_completion

## Alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

## PATH
export PATH="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"

. $HOME/works/linux/resources/.bash_improve
```

## Setup Ubuntu env

Find a vagrant box from <https://vagrantcloud.com>, suppose the box is `ubuntu/trusty64`.

```
$ brew install Caskroom/cask/vagrant
$ brew install Caskroom/cask/virtualbox
$ mkdir vagrant
$ vagrant init ubuntu/trusty64
$ ls .vagrant/machines/default/virtualbox/private_key
$ vim Vagrantfile
config.vm.network "private_network", ip: "192.168.33.10"
config.vm.provider "virtualbox" do |vb|
  vb.gui = false
  vb.memory = "4096"
  vb.cpus = "4"
end
$ vagrant up
$ vagrant ssh
```

## Clear All DNS Servers

If you update the `/etc/resolv.conf` file or use the GUI to update your DNS servers, it will persist.

The following command can be helpful if you're wanting to fall back to DHCP provided DNS from a router, modem, or similar situation:

```
# networksetup -setdnsservers Wi-Fi empty
# networksetup -setsearchdomains Wi-Fi empty
```

## Finally

Fuck all Apple products, including MacBook, iPhone, iPad. Because the filesystem is not case sensitive.
