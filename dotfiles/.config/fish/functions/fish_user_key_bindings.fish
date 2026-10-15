function fish_user_key_bindings
    # Use jk as escape (same in nvim)
    bind -M insert jk fish_escape

    # fzf: ctrl-t files, ctrl-r history, alt-c cd (needs fzf 0.48+)
    if type -q fzf
        fzf --fish | source
        # ctrl-p also finds files, like in nvim
        bind \cp fzf-file-widget
        bind -M insert \cp fzf-file-widget
    end
end

function fish_escape
    if commandline -P
        commandline -f cancel
    else
        set fish_bind_mode default
        commandline -f backward-char force-repaint
    end
end
