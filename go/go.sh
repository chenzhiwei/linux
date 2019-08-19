#!/bin/bash

VERSION=${VERSION:-1.12.4}
DEP_VERSION=${DEP_VERSION:-v0.5.1}
ARCH=$(uname -m|sed 's/x86_64/amd64/g')
KERNAL=$(uname -s|tr '[:upper:]' '[:lower:]')

URL=https://dl.google.com/go/go${VERSION}.${KERNAL}-${ARCH}.tar.gz
DEP_URL=https://github.com/golang/dep/releases/download/${DEP_VERSION}/dep-${KERNAL}-${ARCH}

if type curl &>/dev/null; then
    curl -kL $URL | tar -xz -C /usr/local/
    curl -kL -o /usr/local/bin/dep $DEP_URL
else
    wget -O - $URL | tar -xz -C /usr/local/
    wget -O /usr/local/bin/dep $DEP_URL
fi

chmod +x /usr/local/bin/dep


cat <<'EOF' > $HOME/.golangrc
# GOLANG
[[ $PATH == */usr/local/go/bin* ]] || export PATH=$PATH:/usr/local/go/bin
export GOROOT=/usr/local/go
export GOPATH=$HOME/dev/go
EOF

grep -wq '.golangrc' $HOME/.bashrc || echo '. $HOME/.golangrc' >> $HOME/.bashrc
