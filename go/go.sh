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

chmod +x /usr/local/bin/dep

cat <<'EOF' > $HOME/.golangrc
# GOLANG
[[ $PATH == */usr/local/go/bin* ]] || export PATH=$PATH:/usr/local/go/bin
export GOROOT=/usr/local/go
export GOPATH=$HOME/dev/go
EOF

grep -wq '.golangrc' $HOME/.bashrc || echo '. $HOME/.golangrc' >> $HOME/.bashrc
