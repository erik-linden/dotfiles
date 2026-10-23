# A copy of fish's own up-or-search (/usr/share/fish/functions/), which this
# file replaces, with one line added: `history merge`, so Up also finds
# commands typed in other fish windows since this one started. After a fish
# upgrade, compare with the original if Up behaves oddly.
function up-or-search -d "Depending on cursor position and current mode, either search backward or move up one line"
    # If we are already in search mode, continue
    if commandline --search-mode
        commandline -f history-search-backward
        return
    end

    # If we are navigating the pager, then up always navigates
    if commandline --paging-mode
        commandline -f up-line
        return
    end

    # We are not already in search mode.
    # If we are on the top line, start search mode,
    # otherwise move up
    set -l lineno (commandline -L)

    switch $lineno
        case 1
            commandline -f history-search-backward
            history merge

        case '*'
            commandline -f up-line
    end
end
