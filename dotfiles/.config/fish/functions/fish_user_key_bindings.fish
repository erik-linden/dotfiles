function fish_user_key_bindings
    # like vi, but keep things like ctrl-f
    fish_hybrid_key_bindings
    # remap jk and jj to escape, fish ignores .vimrc
    bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"
    bind -M insert jj "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"
end
