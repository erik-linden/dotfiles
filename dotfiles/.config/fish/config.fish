# empty greeting
set fish_greeting

# default editor
set -gx EDITOR vim

# https://unix.stackexchange.com/questions/230238/starting-x-applications-from-the-terminal-and-the-warnings-that-follow
set -x NO_AT_BRIDGE 1

# remap the section key (left of '1') to '~'
if test $DISPLAY
    xmodmap -e 'keycode 49 = asciitilde'
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /home/tobii.intra/elin/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

# powerline, must be after conda, or conda will overwrite 'fish_left_prompt'
set POWERLINE_CONFIG_COMMAND ~/miniconda3/bin/powerline-config
set POWERLINE_COMMAND ~/miniconda3/bin/powerline
set fish_function_path $fish_function_path ~/miniconda3/lib/python3.10/site-packages/powerline/bindings/fish
powerline-daemon -q
powerline-setup
