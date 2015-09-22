# Gerrit

## 给一个Gerrit Project添加commentlink

* Checkout code and edit project configure file

```
# git clone ssh://username@gerrit.system.com:29418/group/project
# git fetch origin refs/meta/config:refs/remotes/origin/meta/config
# git checkout meta/config
# vim project.config
[commentlink "bugheader"]
match = ([Cc]loses|[Pp]artial|[Rr]elated)-[Bb]ug:\\s*#?(\\d+)
link  = https://bugzilla.xxx.com/?id=$2
```

* Push the changes to gerrit server

```
# git push origin meta/config:meta/config # push directly
# git push origin meta/config:refs/for/refs/meta/config # push via review
```

* Flush the caches

```
# ssh gerrit gerrit flush-caches --cache project_list
# ssh gerrit gerrit flush-caches --cache projects
```

* Reference

<http://www.lowlevelmanager.com/2012/09/modify-submit-type-for-gerrit-project.html>

## Integration

Gerrit + Bugzilla = Perfect!
