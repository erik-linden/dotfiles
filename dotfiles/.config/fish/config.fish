# empty greeting
set fish_greeting

# conda python will be first in PATH
set -x PATH /home/tobii.intra/elin/miniconda3/bin $PATH

# enable `conda activate`
source /home/tobii.intra/elin/miniconda3/etc/fish/conf.d/conda.fish

# powerline, must be after conda
set fish_function_path $fish_function_path ~/miniconda3/lib/python3.6/site-packages/powerline/bindings/fish
powerline-setup

# https://unix.stackexchange.com/questions/230238/starting-x-applications-from-the-terminal-and-the-warnings-that-follow
set -x NO_AT_BRIDGE 1

# cuda paths
set -x PATH /usr/local/cuda-9.1/bin $PATH
set -x LD_LIBRARY_PATH /usr/local/cuda-9.1/lib64 $LD_LIBRARY_PATH

# remap the section key (left of '1') to '~'
xmodmap -e 'keycode 49 = asciitilde'
