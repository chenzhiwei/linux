# How to contribute to project

## Set your SSH key on github

Generate and upload your SSH public key to github.

## Set your git config

See: <https://github.com/chenzhiwei/linux/tree/master/git>

## Fork it on github.com

source repo: `https://github.com/liu21st/thinkphp`
your fork: `https://github.com/chenzhiwei/thinkphp`

## Sync your fork with source repo

```
$ git clone git@github.com:chenzhiwei/thinkphp.git
$ cd thinkphp
$ git remote add upstream https://github.com/liu21st/thinkphp
$ git fetch upstream
$ git checkout master
$ git merge upstream/master
$ git push
```

## Contribute to source repo

```
$ git clone git@github.com:chenzhiwei/thinkphp.git
$ cd thinkphp
$ git checkout master
$ git checkout -b your_feature_or_bugfix_branch
$ vim filename
$ git add .
$ git commit -m"commit msg"
$ git push origin your_feature_or_bugfix_branch
```

Then login to github.com, and send a pull request from your_feature_or_bugfix_branch to upstream master branch.

After the pull request accept, sync your fork with source repo and/or delete the your_feature_or_bugfix_branch branch.

## Rebase your branch

Please take a look at: <https://github.com/chenzhiwei/linux/blob/master/git/how-to-contribute-to-openstack-project.md>

## Solve conflicts on your branch

Please take a look at: <https://github.com/chenzhiwei/linux/blob/master/git/how-to-contribute-to-openstack-project.md>

## Checkout GitHub Pull Request locally

```
$ git clone git@github.com:chenzhiwei/thinkphp.git
$ cd thinkphp
$ git remote add upstream https://github.com/liu21st/thinkphp
$ git fetch upstream
$ git fetch origin pull/123/head:pr-123
```

## Sources

1. <https://help.github.com/articles/generating-ssh-keys>
2. <https://help.github.com/articles/fork-a-repo>
3. <https://help.github.com/articles/using-pull-requests>
4. <https://help.github.com/articles/syncing-a-fork>
