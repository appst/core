# https://unix.stackexchange.com/questions/124407/what-color-codes-can-i-use-in-my-ps1-prompt
# . $PICASSO/core/guest/init.d/PS1.sh

#START_COLOR='\e['
START_COLOR='\[\033'
#STOP_COLOR='\e[m'
STOP_COLOR='\[\033[0m\]'
DARK_YELLOW='[0;33m\]'
LIGHT_YELLOW='[1;33m\]'
#export PS1="$START_COLOR$LIGHT_YELLOW[\$? \h:${SHELL}@\u \$PWD]\$ $STOP_COLOR"
export PS1="${START_COLOR}${LIGHT_YELLOW}[\$? \u@${PSHELL}@\h \w]\$ $STOP_COLOR"
