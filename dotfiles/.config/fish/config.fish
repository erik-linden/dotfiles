if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Empty greeting
set fish_greeting

# Default editor
set -gx EDITOR vim

# https://unix.stackexchange.com/questions/230238/starting-x-applications-from-the-terminal-and-the-warnings-that-follow
set -x NO_AT_BRIDGE 1

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /home/elin/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

# Add to path
fish_add_path ~/.npm-global/bin
fish_add_path ~/.vim/plugged/fzf/bin
fish_add_path ~/.pixi/bin

# Set up fzf key bindings
fzf --fish | source

# Set up starship prompt
starship init fish | source

# Set up pixi completions
pixi completion --shell fish | source
