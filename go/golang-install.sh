#!/bin/bash

ARCH=$(uname -m|sed 's/x86_64/amd64/g')
KERNAL=$(uname -s|tr '[:upper:]' '[:lower:]')
VERSION=$(curl -s https://golang.org/VERSION?m=text)
URL=https://dl.google.com/go/${VERSION}.${KERNAL}-${ARCH}.tar.gz

GOINSTALL=$HOME/.golang/versions/$VERSION
mkdir -p $GOINSTALL

if type curl &>/dev/null; then
    curl -kL $URL | tar -xz -C $GOINSTALL
else
    wget -O - $URL | tar -xz -C $GOINSTALL
fi

\rm -f $HOME/.golang/go
ln -sf $GOINSTALL/go $HOME/.golang/go

cat <<'EOF' > $HOME/.golang/rc
# GOLANG
export GOROOT=$HOME/.golang/go
export GOPATH=$HOME/dev/go
[[ $PATH == *$GOROOT/bin* ]] || export PATH=$GOROOT/bin:$PATH
[[ $PATH == *$GOPATH/bin* ]] || export PATH=$GOPATH/bin:$PATH
EOF

grep -wq '.golang/rc' $HOME/.bashrc || echo '. $HOME/.golang/rc' >> $HOME/.bashrc
