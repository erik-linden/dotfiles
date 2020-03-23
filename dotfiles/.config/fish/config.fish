# empty greeting
set fish_greeting

# conda base is always last in PATH
set -x PATH $PATH /home/tobii.intra/elin/miniconda3/bin

# enable `conda activate`
source /home/tobii.intra/elin/miniconda3/etc/fish/conf.d/conda.fish

# powerline, must be after conda
set fish_function_path $fish_function_path ~/miniconda3/lib/python3.7/site-packages/powerline/bindings/fish
powerline-setup

# https://unix.stackexchange.com/questions/230238/starting-x-applications-from-the-terminal-and-the-warnings-that-follow
set -x NO_AT_BRIDGE 1

# remap the section key (left of '1') to '~'
xmodmap -e 'keycode 49 = asciitilde'
