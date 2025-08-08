#!/bin/bash

source=$1
destination=$2

mv "$1" "$2"
ln -s $2/"$(basename "$1")" "$1"
