alias h='history'
alias j='jobs -l'
alias which='type -a'
alias path='echo -e ${PATH//:/\\n}'
alias du='du -h'
alias df='df -kh'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -la'
alias loacte='locate'
alias ssh="ssh -X"
alias search="grep -rsniH"

alias m='less'
export PAGER=less
export LESS='-eiMSx4 -FX -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
#export LESS='-i -w -g -e -M -R -P%t?f%f \
#:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

#-----------------------------------
# File & strings related functions:
#-----------------------------------

function backup() { cp -i $1 $1~; }
function c () { cd `~thomas/.home-sweet-home/bin/cdbm.pl $1`; pwd;}
function ff() { find . -name '*'$1'*' ; }
function fe() { find . -name '*'$1'*' -exec $2 {} \; ; }
function fstr() # find a string in a set of files
{
    if [ "$#" -gt 2 ]; then
        echo "Usage: fstr \"pattern\" [files] "
        return;
    fi
    SMSO=$(tput smso)
    RMSO=$(tput rmso)
    find . -type f -name "${2:-*}" -print | xargs grep -sin "$1" | \
sed "s/$1/$SMSO$1$RMSO/gI"
}

function cuttail() # cut last n lines in file, 10 by default
{
    nlines=${2:-10}
    sed -n -e :a -e "1,${nlines}!{P;N;D;};N;ba" $1
}

function lowercase()  # move filenames to lowercase
{
    for file ; do
        filename=${file##*/}
        case "$filename" in
        */*) dirname==${file%/*} ;;
        *) dirname=.;;
        esac
        nf=$(echo $filename | tr A-Z a-z)
        newname="${dirname}/${nf}"
        if [ "$nf" != "$filename" ]; then
            mv "$file" "$newname"
            echo "lowercase: $file --> $newname"
        else
            echo "lowercase: $file not changed."
        fi
    done
}

function swap()         # swap 2 filenames around
{
    local TMPFILE=tmp.$$
    mv $1 $TMPFILE
    mv $2 $1
    mv $TMPFILE $2
}

function repeat()       # repeat n times command
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

function show_line() #  show a specific line
{
    awk  "NR==$1-1 || NR==$1 || NR==$1+1" $2
}

