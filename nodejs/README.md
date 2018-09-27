# nodejs

nodejs development environment setup.

## Setup a mirror registry

```
$ vim ~/.npmrc
progress = true
registry = https://registry.npm.taobao.org/
```

## Install nvm

nvm is Node Version Manager.

```
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
```

## Install nodejs

```
$ nvm install stable
$ nvm install 8
$ nvm list
$ nvm use 8
```

## Reference

nvm: https://github.com/creationix/nvm
