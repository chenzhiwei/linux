# Install Ruby Gems


## Install with bundler

Gemfile

```
source 'https://ruby.taobao.org/'
# source 'http://mirrors.aliyun.com/rubygems/'
gem 'rails'
```

Command

```
# bundle install --system
```

## Install with gem

Command

```
# gem sources --remove https://rubygems.org/
# gem sources -a https://ruby.taobao.org/
# gem sources -l
# gem install rails
```
