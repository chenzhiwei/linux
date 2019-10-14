#!/bin/bash

VERSION=${VERSION:-1.13.1}
ARCH=$(uname -m|sed 's/x86_64/amd64/g')
KERNAL=$(uname -s|tr '[:upper:]' '[:lower:]')
URL=https://dl.google.com/go/go${VERSION}.${KERNAL}-${ARCH}.tar.gz

if type curl &>/dev/null; then
    curl -kL $URL | sudo tar -xz -C /usr/local/
else
    wget -O - $URL | sudo tar -xz -C /usr/local/
fi

cat <<'EOF' > $HOME/.golangrc
# GOLANG
export GOROOT=/usr/local/go
export GOPATH=$HOME/dev/go
[[ $PATH == *$GOROOT/bin* ]] || export PATH=$PATH:$GOROOT/bin
[[ $PATH == *$GOPATH/bin* ]] || export PATH=$PATH:$GOPATH/bin
EOF

grep -wq '.golangrc' $HOME/.bashrc || echo '. $HOME/.golangrc' >> $HOME/.bashrc
