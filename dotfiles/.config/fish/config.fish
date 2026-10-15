# Empty greeting
set -g fish_greeting

# Vi mode, but keep emacs bindings like ctrl-f/ctrl-a/ctrl-e in insert mode.
# Extra bindings (jk to escape, fzf) are in functions/fish_user_key_bindings.fish
set -g fish_key_bindings fish_hybrid_key_bindings

# Default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Add to path (-g: only for this session, nothing is saved in fish_variables)
fish_add_path -g ~/.local/bin
fish_add_path -g ~/.pixi/bin

# fzf colors (see docs/palette.md), and use ripgrep to list files (respects .gitignore)
set -gx FZF_DEFAULT_OPTS "--color=bg+:#3c3836,bg:#1d2021,spinner:#89b482,hl:#7daea3,fg:#d4be98,header:#7daea3,info:#d8a657,pointer:#89b482,marker:#89b482,fg+:#ddc7a1,prompt:#d8a657,hl+:#7daea3,border:#504945"
if type -q rg
    set -gx FZF_DEFAULT_COMMAND "rg --files --hidden --glob '!.git'"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
end

# less: keep colors in piped text (-R), and quit right away if it all fits on
# one screen (-F). Use `--color=always` or `unbuffer cmd` for programs that
# turn colors off when piped.
set -gx LESS -FR

# bat (apt: bat, linked as ~/.local/bin/bat): syntax highlighting for files,
# --help output (`h <command>`) and man pages
if type -q bat
    set -gx BAT_THEME gruvbox-dark
    set -gx MANPAGER "sh -c 'col -bx | bat --language=man --plain'"
    set -gx MANROFFOPT -c
end

if status is-interactive
    # Muscle memory: typing `vim` expands to `nvim` (press space to see it)
    if type -q nvim
        abbr -a vim nvim
        abbr -a vimdiff nvim -d
    end

    # kitty's terminfo is missing on most servers; this copies it over on ssh
    if test "$TERM" = xterm-kitty; and type -q kitten
        abbr -a ssh kitten ssh
    end

    # Set up starship prompt
    type -q starship; and starship init fish | source

    # zoxide: `z proj` jumps to the most used directory matching "proj",
    # `zi` picks one with fzf. Plain `cd` still works and feeds it.
    type -q zoxide; and zoxide init fish | source

    # Set up pixi and uv completions
    type -q pixi; and pixi completion --shell fish | source
    type -q uv; and uv generate-shell-completion fish | source
end
