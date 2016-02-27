# nodejs

## Setup a mirror registry

```
$ vim ~/.npmrc
registry = https://registry.npm.taobao.org/
```

## Install a node package globally

```
$ sudo npm install -g hexo-cli
```

## Update the package.json file

```
$ sudo npm install -g npm-check-updates
$ cd hexo
$ ls package.json
$ npm-check-updates -u
$ npm install
```

Sometimes, using `npm-check-updates -u -a`.

## Issues

When using `sudo npm install` will make some packages under `~/.npm/some-package` to be root owner, so run `sudo chown -R $USER:$USER` to change them.

In Ubuntu system, when you `sudo user`, the `$HOME` still `/home/user`.
