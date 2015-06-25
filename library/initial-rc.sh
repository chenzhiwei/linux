#!/bin/bash

# Create ~/.screenrc
function screenrc() {
    curl -o ~/.screenrc -sSL https://github.com/chenzhiwei/linux/raw/master/screen/.screenrc
}

# Create ~/.gitconfig
function gitconfig() {
    curl -o ~/.gitconfig -sSL https://github.com/chenzhiwei/linux/raw/master/git/.gitconfig
}

# Create ~/.vimrc
function vimrc() {
    rm -rf ~/.vim
    git clone --recursive https://github.com/chenzhiwei/dot_vim.git ~/.vim
    ln -sf ~/.vim/dot_vimrc ~/.vimrc
}

screenrc
gitconfig
vimrc
