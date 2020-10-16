
# ---------- ---------- ---------- ---------- ----------
# http://stackoverflow.com/questions/11904907/redirect-stdout-and-stderr-to-function

YOGA_LOGFILE=${YOGA_LOGFILE:-$ROOT_PICASSO/log/installs}
YOGA_LOGSPEC=${YOGA_LOGSPEC:-$_TOP_:$LINENO}  # default of what to include in log

function _log() {
echo "_log YOGA_LOGSPEC: $(eval "echo $YOGA_LOGSPEC")"

if [ -n "$1" ]; then
IN="$1"
else
read -t 0.1 IN  # This reads a string from stdin and stores it in a variable called IN
fi

DateTime=`date "+%Y/%m/%d %H:%M:%S"`
#  echo '*****'$DateTime' ('${!YOGA_LOGSPEC}'): '$IN >> "$YOGA_LOGFILE"
#  echo $DateTime' ('${!YOGA_LOGSPEC}'): '$IN
echo '*****'$DateTime' ('$(eval "echo $YOGA_LOGSPEC")'): '$IN >> "$YOGA_LOGFILE"
echo $DateTime' ('$(eval "echo $YOGA_LOGSPEC")'): '$IN
}
export -f _log

:<<\_x
echo "This statement is piped to _log" | _log
EchoErr "This statement is an error" 2>&1 | _log
_log "This statement is sent to _log"
_x
