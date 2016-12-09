# git的相关配置

## 使用git

搭建gitserver： <https://github.com/chenzhiwei/linux/blob/master/git/build-git-server.mkd>

### 全局设置

```
$ git config --global user.name "Chen Zhiwei"
$ git config --global user.email zhiweik@gmail.com
```

配置完成之后会在$HOME目录下生成一个.gitconfig配置文件，具体参考[示例](https://github.com/chenzhiwei/linux/blob/master/git/.gitconfig)。

`--local` 是将这些内容写入 project 下的 .git/config 文件中，每个project都可以有不同的配置。

### 自动补全

如果你系统上安装git之后没有自动补全功能，可以按如下操作来添加补全功能，记得需要重新登录一下。

```
$ wget -O /etc/profile.d/git-completion.sh https://raw.github.com/git/git/master/contrib/completion/git-completion.bash
```

### 开始使用

* 创建新的git仓库

```
$ mkdir git_repo
$ cd git_repo
$ git init
$ echo "test" > README.mkd
$ git add README.mkd
$ git commit -m "add README.mkd file"
$ git remote add origin git@github.com:username/test.git
$ git push -u origin master
```

* 使用已存在的git仓库

```
$ cd git_repo
$ git remote add origin git@github.com:username/test.git
$ git push -u origin master
```
注意，如果提示`fatal: remote origin already exists.`，那么说明该本地仓库已经有远端地址了。你可以先使用`git remote rm origin`删除origin，或者使用`git remote add other_name git@github.com:username/test.git`来添加（提交时记得使用`git push -u other_name master`）。

## 为本地仓库创建两个镜像
假设现有仓库地址为： git@github.com:chenzhiwei/linux.git

```
$ git clone git@github.com:chenzhiwei/linux.git
$ cd linux
$ git remote add backup git@gitcafe.com:chenzhiwei/linux.git
$ git push -u backup master
```
之后每次修改时，在最后push的时候需要执行两条命令：

```
$ git push origin
$ git push backup
```
如果要只执行一次push就提交到两个远端仓库，那么需要修改仓库根目录下的.git/config文件，添加以下内容：

```
[remote "both"]
    url = git@github.com:chenzhiwei/linux.git
    url = git@gitcafe.com:chenzhiwei/linux.git
```
然后在提交更新时使用`git push both`就可以将更新提交到两个远端仓库了。

或者直接把 backup 分支的地址写到 origin 分支这里：

```
[remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*
    url = git@github.com:chenzhiwei/linux.git
    url = git@gitcafe.com:chenzhiwei/linux.git
```

注意：在 Git 2.0 将会更改默认的`push`动作为『只 push 当前 branch 到远端仓库』。如果想继续使用`git push both`命令需要手动设置一下`git push`的默认动作`git config --global push.default matching`。

`push.default`有几个简单动作，这里介绍`matching`和`simple`，二者[意思][push.default]分别是 push 本地所有的分支到远端仓库和 push 本地当前分支到上游分支。这个解释貌似还不够精确，可以`man git-config`来查看详细说明。

[push.default]: http://stackoverflow.com/questions/13148066/warning-push-default-is-unset-its-implicit-value-is-changing-in-git-2-0

一个完整的.git/config文件示例如下：

```
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
[remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*
    url = git@github.com:chenzhiwei/linux.git
[branch "master"]
    remote = origin
    merge = refs/heads/master
[remote "backup"]
    url = git@gitcafe.com:chenzhiwei/linux.git
    fetch = +refs/heads/*:refs/remotes/backup/*
[remote "both"]
    url = git@github.com:chenzhiwei/linux.git
    url = git@gitcafe.com:chenzhiwei/linux.git
```

## 在现有仓库上创建孤儿分支

孤儿分支意思为该分支中没有任何内容，与之前创建的其他分支没有任何关联。

```
$ git clone git@github.com:chenzhiwei/test.git
$ cd test
$ git checkout --orphan new_branch
Switched to a new branch 'new_branch'
$ git rm -rf . # 删除旧工作目录树中所有文件
$ rm .gitignore # 如果有该文件的话就删除
$ echo "orphan branch" > README.mkd
$ git add .
$ git commit -m "add README.mkd file"
$ git push origin new_branch
```

## 提交单个分支到远端git仓库

`git push`命令默认是将所有分支(branch)都提交到git仓库，有时你只想提交某个分支到远端仓库，那么就就需要使用`git push origin HEAD`。当然也可以使用`git config --global push.default tracking`命令来改变`git push`的默认操作，意思是执行`git push`时默认只提交当前分支到远端git仓库。

## git常用指令

以下几个是git常用的指令，可以简单了解一下。

### git config

在使用git前最好先配置一下你的个人信息及使用偏好。以下命令的意思就不用解释了吧，执行完以下命令就会在你的家目录（~）下生成一个文件`~/.gitconfig`。

```
$ git config --global user.name "Chen Zhiwei"
$ git config --global user.email zhiweik@gmail.com
$ git config --global core.editor vim
$ git config --global merge.tool vimdiff
$ git config --global color.status auto
$ git config --global color.branch auto
$ git config --global color.interactive auto
$ git config --global color.diff auto
$ git config --global push.default simple
$ git config --global alias.co checkout
$ git config --global alias.ci commit
$ git config --global alias.st status
$ git config --global alias.last 'log -1 HEAD'
$ git config --global alias.unstage 'reset HEAD --'
```

### git add

添加文件内容到索引中去（暂存文件），几个简单示例：

```
$ git add .
$ git add --all
$ git add *.txt
$ git add directory/*.sh
```

突然你又不想`git add`了，那么执行以下命令：

```
$ git reset .
$ git reset *.txt
$ git reset directory/*.sh
```

### git rm

删除索引和当时工作目录中的文件。

```
$ git rm filename
$ git rm -f *.txt
$ git rm -r .
```

### git commit

将当前改动记录到仓库中，即提交改动到本地仓库中。

```
$ git commit -m "add a file and remove a file"
```

突然你又不想`git commit`了，那么执行以下命令:

```
$ git reset HEAD^
```

你`commit`之后发现少添加了一个文件：

```
$ git commit -m'msg'
$ git add forget_file
$ git commit --amend
```

你的 commit 已经 push 到远程分支(master)了，现在你想反悔了：

```
$ git clone git@github.com:chenzhiwei/test.git
$ cd test
$ git reset HEAD^
$ git push -f master 
```

### git status

查看当前工作目录的状态，即修改、添加及删除了哪些文件。

```
$ git status
```

### git checkout

检出一个分支和目录到当前工作目录中，可以简单理解为切换分支的命令。

以下命令分别为切换到分支 branch1 和创建一个新的分支 new_branch 。

```
$ git checkout branch1
$ git checkout -b new_branch
```

取消本地改动：

```
$ git checkout -- file_name
```

### git branch

* 列出、创建和删除分支。

以下指令分别为列出本地分支、所有分支、远端分支、创建、删除、强制删除分支。

```
$ git branch --list
$ git branch --all
$ git branch --remotes
$ git branch new_branch
$ git branch --delete branch_name
$ git branch -D branch_name
```

删除remote tracking branch，就是`git branch -r`命令列出的分支。

```
$ git branch -r
$ git branch -d -r origin/develop
```

* 合并分支

如果出现冲突，那么手动解决冲突就可以了。

```
$ git checkout branch_name
$ git checkout master
$ git merge branch_name
```

* 删除远程分支

合并分支之后如果不再需要以前的分支了，那么可以在本地及远程删除它。

```
$ git branch -d branch_name
$ git branch -D branch_name
$ git push origin :branch_name
```

这条命令耐人寻味啊，其中`origin`是你的远程仓库名字（`git remote -v`可以查看到）。

### git diff

查看改动内容。

```
$ git diff filename
$ git diff .
$ git diff revision1 revision2
$ git diff branch1 branch2
```

DIFF暂存（添加到索引中）的文件：

```
$ git add .
$ git diff --cached
```

View the redundant Tab or Space in your codes:

```
$ git diff --check
$ git diff --check --cached
```

只查看更改了哪些文件:

```
$ git diff --name-only
```

### git init

### git log

查看修改日志。

**git log -- filename**

查看某个文件（包括已删除的文件）的修改历史，输出为commit info。

**git log -p -- filename**

查看某个文件（包括已删除的文件）的修改历史，输出为commit info和diff。

### git merge

### git mv

### git pull

### git push

### git rebase

你检索出代码之后（假设是master分支），创建了一个分支，然后修改了这个分支。另一个人也检索出代码（假设是master分支），然后修改了这个分支并提交到远端了。这时你需要重新从远端检索一下（master）分支的代码，然后切换到你创建的那个分支，再执行`rebase`命令，因为你这个分支的 base 分支已经发生变化了，你要合并到 base 分支的话需要重新 rebase 一下。

```
$ git clone -b master git@github.com:chenzhiwei/test.git
$ git checkout -b new_branch
$ git checkout master
$ git pull
$ git checkout new_branch
$ git rebase
$ git rebase --continue
```

你执行`git rebase`之后可能会有文件冲突，这时你需要手动解决冲突，解决之后继续rebase。

### git cherry-pick

把已经提交的commit从一个分支移动到另一个分支。使用场景如下：

你有两个分支分别是master和stable，并且stable是master的一个历史commit。有一个bug存在于stable中，很明显这个bug也会存在于master中，你在stable里修复了这个bug，现在你也要在master里修复这个bug，这时你就需要使用cherry-pick把修复这个bug的commit移动到master分支里。

```
$ git checkout stable
$ git commit -m"fix a bug" # commit id: 2ea0234b1fa6
$ git checkout master
$ git cherry-pick 2ea0234b1fa6
$ vim xxx # solve conflicts
$ git commit -c 2ea0234b1fa6
```

### git revert

### git reset

一不小心执行了`git add .`，然后就可以用`git reset`命令来破了。

删除最近一次 commit ，但保留这次 commit 中修改的内容，即用`git status`来查看会显示有文件等待提交。

```
$ git reset --soft HEAD^
```

删除最近一次 commit ，并且不保留这次 commit 中的修改内容，即用`git status`来查看会显示没有改动。

```
$ git push --force
```

更新到远程仓库

### git stash

当你修改了本地仓库的文件，但又想放弃修改时，可以用`git stash`来还原到仓库原来的状态。

### git submodule

git 是分布式的，每次只能将整个 repo 全部下载下来进行更改提交，这样明显不太合理，因为很多时候你只想改动一点代码，只需要将这部分代码所在的目录 clone 下来就行了。为了解决这个问题，git 引入了 submodule ，即一个 git repo 里可以包含多个 child git repo 。

一个比较大的项目，里面肯定会包含很多模块及子项目，可以将这些模块和子项目分别做成 git repo ，然后用大项目的 git repo 将其包含进来就可以了，举例如下：

一个项目（foo）包含了一个子项目(bar)，主项目的 repo 是 `https://github.com/chenzhiwei/linux`，子项目的 repo 地址是 `https://github.com/chenzhiwei/vim`，需要做以下操作来完成 git submodule 的创建。

```
$ git clone https://github.com/chenzhiwei/linux
$ cd linux
$ git submodule add https://github.com/chenzhiwei/vim vim
$ git status
$ git commit -m"add a submodule vim"
```

`git submodule add`命令会生成一个`.gitmodules`文件，并且当前目录下也会出现`vim`这个 repo 。

其他人 clone 时默认是不会将`vim`的代码clone下来的，并且`vim`这个 submodule 体现在本地文件系统上是个目录，而在 git repo 里其实是一个空的文本文件。如果想将 submodule 即子项目的代码也全部 clone 下来，你需要执行以下操作：

```
$ git clone https://github.com/chenzhiwei/linux
$ cd linux
$ git submodule init
$ git submodule update
```

删除 submodule

```
$ git rm -r submodule
```

### git tag

个人感觉功能比branch强大点，因为tag里可以加注释。

```
$ git tag -a tagname -m"tag message"
$ git tag tagname -f -m"new tag message"
$ git push origin tagname
$ git push orgin :tagname
$ git push --delete orgin tagname
$ git push orgin :refs/tags/tagname
```

### git blame

查看某个文件当前内容的修改记录，即都在哪个commit中被谁修改的。

```
$ git blame filename
```

会列出filename文件中所有行都是在什么时候被添加的、被谁添加的以及被谁在哪个commit里添加的。

## 其他

### 给自己项目在github上创建一个mirror

```
# In this example, we use an external account named extuser and
# a GitHub account named ghuser to transfer repo.git

git clone --bare https://githost.org/extuser/repo.git
# Make a bare clone of the external repository to a local directory

cd repo.git
git push --mirror https://github.com/ghuser/repo.git
# Push mirror to new GitHub repository

cd ..
rm -rf repo.git
# Remove temporary local repository
```

### git 上游源更新合并

查看本地远程库

```
$ git remote -v
```
添加上游仓库源

```
$ git remote add upstream https://github.com/....git
$ git remote -v         #再次查看
$ git fetch upstream    #更新上游仓库代码
$ git checkout master    #转到 master库中
$ git merge upstream/master    #合并上游库代码
$ git commit            #提交到自己的
$ git push
```

