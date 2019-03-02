function fish_user_key_bindings
    # Like vi, but keep things like ctrl-f
    fish_hybrid_key_bindings
    # Use jj and jk as escape keys
    bind -M insert jj fish_escape
    bind -M insert jk fish_escape
end

function fish_escape
    if commandline -P
        commandline -f cancel
    else
        set fish_bind_mode default
        commandline -f backward-char force-repaint
    end
end

fzf_key_bindings
