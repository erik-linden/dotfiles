function rcd --description "ranger, and cd to the directory it was in when quitting"
    set -l tmp (mktemp)
    ranger --choosedir=$tmp $argv
    set -l dir (cat $tmp)
    rm -f $tmp
    if test -n "$dir"; and test "$dir" != "$PWD"
        cd $dir
    end
end
