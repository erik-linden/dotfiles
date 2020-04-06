# empty greeting
set fish_greeting

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /home/tobii.intra/elin/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

# powerline, must be after conda
set fish_function_path $fish_function_path ~/miniconda3/lib/python3.7/site-packages/powerline/bindings/fish
powerline-setup

# https://unix.stackexchange.com/questions/230238/starting-x-applications-from-the-terminal-and-the-warnings-that-follow
set -x NO_AT_BRIDGE 1

# remap the section key (left of '1') to '~'
xmodmap -e 'keycode 49 = asciitilde'
