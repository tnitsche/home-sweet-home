# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

set -o notify
set -o noclobber
set -o ignoreeof

shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s mailwarn
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s histappend histreedit
shopt -s extglob

export PATH

export REPLYTO="thomas.nitsche@gmail.com"
export VISUAL=/usr/bin/vim
export EDITOR=/usr/bin/vim

#-----------------------------------
# File & strings related functions:
#-----------------------------------

function backup() { cp -i $1 $1~; }
function c () { cd `~thomas/bin/cdbm.pl $1`; pwd;}
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

shopt -s extglob        # necessary

complete -A hostname   telnet ftp ping disk ssh scp
complete -A command    nohup exec eval trace gdb strace
complete -A command    command type which
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # currently same as builtins
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir

complete -f -X '*.gz'   gzip
complete -f -X '!*.gz'  gunzip
complete -f -X '!*.ps'  gs ghostview gv
complete -f -X '!*.pdf' acroread
complete -f -X '!*.+(gif|jpg|jpeg|GIF|JPG|bmp)' xv gimp
source /etc/bash_completion.d/git

if [ "\$(type -t __git_ps1)" ]; then
  PS1="$PS1\$(__git_ps1 '(%s) ')"
fi

[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm