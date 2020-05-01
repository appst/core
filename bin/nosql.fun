[[ -v NOSQL_STORE ]] || return 1

case $NOSQL_STORE in
mongodb) . $PICASSO/core/bin/mongo.fun;;
*) return 1;;
esac

return 0
