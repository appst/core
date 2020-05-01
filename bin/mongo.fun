:<<\_c
. $PICASSO/core/bin/mongo.fun

USER_ID: a user uuid that is analogous to a mongo collection
SERVER_ID: a VM uuid that is analogous to a mongo document
_c

MONGODB_IP=${MONGODB_IP:-localhost}
MONGODB_PORT=${MONGODB_PORT:-27017}
MONGODB_PICASSO_USER=${MONGODB_PICASSO_USER:-picasso}
MONGODB_PICASSO_USER_PASSWORD=${MONGODB_PICASSO_USER_PASSWORD:-picasso}
#alias mongo='mongo --host $MONGODB_IP --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso'  # creates database 'picasso' the first time it is accessed


# ----------
:<<\__c
db.<collection>.<document>
db.<user_id>.<server_id>

[usage]
USER_ID=user_id
SERVER_ID=server_id
cat $file | _nosql_create_document $USER_ID $SERVER_ID  # returns $server_id
cat $file | _nosql_create_document $USER_ID  # returns $server_id
_nosql_create_document $USER_ID $SERVER_ID $file  # returns $server_id
_nosql_create_document $USER_ID "" $file  # returns $server_id
__c


function _nosql_create_document() {

#[[ $DEBUG -gt 0 ]] && _warn '$DEBUG -gt 0'

{  # capture stdout

#local user_id=$1
local server_id=${2:-$(uuidgen)}
local file=$3

if [[ -f $file ]]; then

#_debug "server_id: $server_id"
#_debug3 "$(cat $file)"
#_debug2 "$(jq --arg a "$server_id" '._id = $a' "$file")"

#/usr/bin/mongo --host $MONGODB_IP --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso \
_mongo \
  --quiet --eval "db.${1}.insertOne( $(jq --arg a "$server_id" '._id = $a' "$file") )"  # insert a document into a collection

else

#_debug "mktemp"

:<<\_s
file="$(mktemp)"

while read -r line
do
_debug "$line"
echo "$line" >> $file
done < /dev/stdin

_debug "server_id: $server_id"
_debug3 "$(cat $file)"
_debug2 "$(jq --arg a "$server_id" '._id = $a' "$file")"
_debug2 "$(cat - | jq --arg a "$server_id" '._id = $a')"

mongo --eval "db.${1}.insertOne( $server_id, $(jq --arg a "$server_id" '._id = $a' "$file") )"  # insert a document into a collection
rm $file
_s

#/usr/bin/mongo --host $MONGODB_IP --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso \
_mongo \
  --quiet --eval "db.${1}.insertOne( $(cat - | jq --arg a "$server_id" '._id = $a') )"  # insert a document into a collection
:<<\_x
/usr/bin/mongo --host localhost --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso \
  --eval "db.${1}.insertOne( $(cat - | jq --arg a "$server_id" '._id = $a') )"  # insert a document into a collection
_x

fi

} 1>/dev/null

echo $server_id
}
:<<\_x
/usr/bin/mongo --host $MONGODB_IP --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso \
  --eval "db.${USER_ID}.insertOne( $(echo '{ "_id": "12345", "foo": "bar" }' | jq --arg a "$SERVER_ID" '._id = $a') )"
_x
:<<\_x
cat > test.json <<!
{ "_id": "12345", "foo": "bar" }
!
file=test.json

USER_ID=user1
SERVER_ID=vm1

cat $file | _nosql_create_document $USER_ID $SERVER_ID  # returns $server_id
_nosql_create_document $USER_ID $SERVER_ID $file  # returns $server_id
cat $file | _nosql_create_document $USER_ID  # returns $server_id
_x


# ----------
:<<\__c
retrieve a document from a collection

[usage]
_nosql_get_document $USER_ID $SERVER_ID  # returns document where _id = $server_id
__c

function _nosql_get_document() {
#local user_id=$1
#local server_id=$2

#/usr/bin/mongo --host $MONGODB_IP --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso \
 _mongo \
 --quiet --eval "db.${1}.findOne( { _id: \"$2\" } )"
}
:<<\_x
mongo --eval "db.${USER_ID}.findOne( { _id: \"$SERVER_ID\" } )"
_x


# ----------
:<<\__c
update a document's key with a new value

_nosql_set <USER_ID> <SERVER_ID> <key> <value>

db.collection.updateOne(<filter>, <update>, <options>)

db.<collection>.<document>
__c

function _nosql_set() {
#local user_id=$1
#local server_id=$2
#local key=$3
#local value=$4

#_debug "_nosql_set MONGODB_IP: $MONGODB_IP, MONGODB_PORT: $MONGODB_PORT $@"

#/usr/bin/mongo --host $MONGODB_IP --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso \
_mongo \
  --quiet --eval "db.${1}.updateOne( { _id: \"$2\" }, { \$set: { \"$3\": \"$4\" } } )"
}
:<<\_x
USER_ID=user_id

SERVER_ID=$(echo '{ "_id": "12345", "foo": "bar" }' | _nosql_create_document $USER_ID "")

key=foo
value=barz
mongo --eval "db.${USER_ID}.updateOne( { _id: \"$SERVER_ID\" }, { \$set: { \"$key\": \"$value\" } } )"

_nosql_set $USER_ID $SERVER_ID foo foo
_nosql_set $USER_ID $SERVER_ID hello world  # appends new key/value
_x


# ----------
:<<\__c
retrieve a document from a collection

[usage]
_nosql_get $USER_ID $SERVER_ID $key # returns value of key where document _id = $SERVER_ID
__c

function _nosql_get() {
#local user_id=$1
#local server_id=$2
#local key=$3

#/usr/bin/mongo --host $MONGODB_IP --port $MONGODB_PORT -u $MONGODB_PICASSO_USER -p $MONGODB_PICASSO_USER_PASSWORD picasso \
_mongo \
  --quiet --eval "db.${1}.findOne( { _id: \"$2\" } )[\"$3\"]"
}
:<<\_x
mongo --quiet --eval "db.${USER_ID}.findOne( { _id: \"$SERVER_ID\" } )['foo']"

_nosql_get $USER_ID $SERVER_ID foo
_x


# ----------
# test all...

:<<\_x
USER_ID=user_id
SERVER_ID=$(echo '{ "_id": "12345", "foo": "bar" }' | _nosql_create_document $USER_ID "")
_nosql_set $USER_ID $SERVER_ID foo foo
_nosql_get $USER_ID $SERVER_ID foo
_nosql_set $USER_ID $SERVER_ID hello world
_nosql_get_document $USER_ID $SERVER_ID
_x

