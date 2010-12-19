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
export LESSOPEN='|lesspipe.sh %s'  # Use this if lesspipe.sh exists 
export LESS='-i -w -g -e -M -R -P%t?f%f \
:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'


