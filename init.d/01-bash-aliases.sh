(( PDEBUG < 3 )) || echo -e "\e[0;43m>>> ${BASH_SOURCE[0]}\e[0m"  #]

# Aliases are expanded when a function definition is read, not when the function is executed, because a function definition is itself a compound command. As a consequence, aliases defined in a function are not available until after that function is executed. 

shopt -s expand_aliases  # 36hr bug
# 36hr bug - i did not realize this was essential and then vagrant kept reporting a bogus error that threw me off 
# The configured shell (config.ssh.shell) is invalid and unable
# to properly execute commands. The most common cause for this is
# using a shell that is unavailable on the system. Please verify
# you're using the full path to the shell and that the shell is
# executable by the SSH user.


# ----------
alias __t=': <<"__t"'
alias __t-='alias __t=": <<\"__t\""'  # __t
alias __t+='alias __t=""'


/usr/bin/env | /bin/grep -q '^TEST=' && {
if [[ ${TEST} -lt 0 ]]; then  # no testing
alias __t=': <<"__t"'
elif [[ ${TEST} -eq 0 ]]; then  # standard testing
alias __t=''  # __t
fi
}


# ----------
case $PSHELL in
wsl*)

# wslpath is missing the '-p' option

function convertpath() {
if [[ $1 == '-u' && $2 =~ /mnt/ ]]; then
echo $2
else
[[ -n "$@" ]] && echo $($PROOT/bin/wslpath.py "$@")
fi
# return $?
}
export -f convertpath

;;
cygwin)
alias clear='printf "\033c"'
alias convertpath='cygpath.exe'
;;
esac


# ----------
(( PDEBUG < 3 )) || echo -e "\e[2;30;43m<<< ${BASH_SOURCE[0]}\e[0m"  #]

true
