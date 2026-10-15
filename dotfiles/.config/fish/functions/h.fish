function h --description "Show a command's --help in color, paged: h docker run"
    # (fish's own `help` opens the fish documentation)
    $argv --help 2>&1 | bat --plain --language=help
end
