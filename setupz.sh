#!/bin/bash

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -s $CONFIG_DIR $HOME/.zsh;
ln -s $CONFIG_DIR/zshrc $HOME/.zshrc;
