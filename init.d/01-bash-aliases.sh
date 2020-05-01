(( PDEBUG < 3 )) || echo -e "\e[0;43m>>> ${BASH_SOURCE[0]}\e[0m"  #]

# Aliases are expanded when a function definition is read, not when the function is executed, because a function definition is itself a compound command. As a consequence, aliases defined in a function are not available until after that function is executed. 

shopt -s expand_aliases  # 36hr bug
# 36hr bug - i did not realize this was essential and then vagrant kept reporting a bogus error that threw me off 
# The configured shell (config.ssh.shell) is invalid and unable
# to properly execute commands. The most common cause for this is
# using a shell that is unavailable on the system. Please verify
# you're using the full path to the shell and that the shell is
# executable by the SSH user.

alias __bug=':<<"__bug"'

# execute a block of script if we are running within the associated OS
#alias _cygwin='[[ ! "$PSHELL" == "cygwin" ]] && :<<"_cygwin"'
#alias _fedora='[[ ! "$OS" == "fedora" ]] && :<<"_fedora"'
alias __cygwin=':<<"__cygwin"'
#[[ "$PSHELL" == "cygwin" ]] && alias __cygwin=':<<"__cygwin"'


#alias _is_installed2='dpkg-query -W -f='\''${Status} ${Version}\n'\'''

# wslpath is missing the '-p' option
case $PSHELL in
wsl*)
#alias convertpath='wslpath'
#alias convertpath='cygpath.exe'

:<<\_c
NB: don't output anything else
_c
function convertpath() {
if [[ $1 == '-u' && $2 =~ /mnt/ ]]; then
echo $2
else
[[ -n "$@" ]] && echo $($PROOT/bin/wslpath.py "$@")
fi
}
export -f convertpath
;;
cygwin)
alias clear='printf "\033c"'
alias convertpath='cygpath.exe'
;;
esac

(( PDEBUG < 3 )) || echo -e "\e[2;30;43m<<< ${BASH_SOURCE[0]}\e[0m"  #]

true
