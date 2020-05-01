
:<<\_c
. $PICASSO/core/bin/sed.fun

devstack's iniset would insert content at the very beginning of sections
devstack's local.conf/localrc execute content sequentially
this posed a problem for adding new lines to localrc, because new commands that should be appended were always prepended
the following hack relies on a comment added to the section that indicates its end
new content is prepended just before this terminator, which is to say, it is appended to the bottom of the existing section's content just like we want
_c
:<<\_c
address space is '/$lead/,/$tail/'
braces denote compound sed commands to apply to address space
append(a) and insert(i) must be followed by a newline, then the content, then another newline
_c

function _section_insert_before_tail() {
# $1: lead
# $2: tail
# $3: destination file
#insert=$(while read i; do printf "$i\\\n"; done)
insert=$(while read i; do [[ -n "$i" ]] && printf "%s\\\n" "$i"; done)
#_debug "grep -q $1 $3"
#ls -l $3

grep -q "$1" $3
if [[ $? -eq 0 ]]; then
#_debug "sed -i /$1/,/$2/{ /$1/n; /$2/i$insert} $3"
sed -i "/$1/,/$2/{ /$1/n; /$2/i$insert
}" $3
else
#_debug "cat $1 -> $3"
cat << EOF >> $3
$1
$insert
EOF
fi
}
export -f _section_insert_before_tail

:<<\_x
cat <<! > $LOCAL_CONF
[[local|localrc]]
enable_service=h-eng h-api h-api-cfn h-api-cw

[[post-config|\$NOVA_CONF]]
[DEFAULT]
flat_injected = True
[mysqld]
!

_section_insert_before_tail '^\[\[local|localrc\]\]' '^\[\[' "$LOCAL_CONF" <<EOF
test
EOF
cat $LOCAL_CONF
#[OK]

cat <<! > $LOCAL_CONF
[[local|localrc]]
enable_service=h-eng h-api h-api-cfn h-api-cw
!

_section_insert_before_tail '^\[\[local|localrc\]\]' '^\[\[' "$LOCAL_CONF" <<EOF
test
EOF
cat $LOCAL_CONF
#[FAIL] - our source file has no 'tail' and therefore nothing happens

# explicitly provide a unique string in the source file that we use as 'tail'
cat <<! > $LOCAL_CONF
[[local|localrc]]
enable_service=h-eng h-api h-api-cfn h-api-cw
#[[local|localrc]]
!

_section_insert_before_tail '^\[\[local|localrc\]\]' '^#\[\[local|localrc\]\]$' "$LOCAL_CONF" <<EOF
test
EOF
cat $LOCAL_CONF
#[OK]

cat <<! > $LOCAL_CONF
[[local|localrc]]
enable_service=h-eng h-api h-api-cfn h-api-cw
#[[local|localrc]]
!

alias _add_localrc='_section_insert_before_tail "^\[\[local|localrc\]\]" "^#\[\[local|localrc\]\]$"'

_add_localrc <<EOF
test
EOF

_add_localrc <<< "section=1"

cat $LOCAL_CONF
#[OK]
_x


# ---------- ---------- ---------- ---------- ----------
function _strip() {
# remove all __c, __s, __t & __x heredocs
# USAGE: cat hosts.sh | _strip > /tmp/hosts

sed -e '/^__c/,/^__c/d' -e '/^__s/,/^__s/d' -e '/^__t/,/^__t/d' -e '/^__x/,/^__x/d'
}
export -f _strip


# ---------- ---------- ---------- ---------- ----------
:<<\_c
replace a string with a match in a file - does nothing if no match was found 
_replace <old string> <new string> <file>
_replace <old string> <new string> <section> <file>

_replace "^auth_host.*" "#&" /etc/glance/glance-api.conf
_c

function _replace() {
if [[ "$#" -eq 3 ]]; then
sed -i "s~$1~$2~g" $3
elif [[ "$#" -eq 4 ]]; then
sed -i "/$3/,/^\[/{ s~$1~$2~g }" $4
fi
}
export -f _replace


# ---------- ---------- ---------- ---------- ----------
:<<\_c
append a string after the match in a file - does nothing if no match was found 
_append <string> <match> <file>

_append "admin_token=$ADMIN_TOKEN" "^\[DEFAULT\]" /etc/keystone/keystone.conf
_c

function _append() {
sed -i "/$2/ a$1" $3
}
export -f _append


# ---------- ---------- ---------- ---------- ----------
function _get_value() {

v=$(grep $1 $2) || return 1
echo -e $v | awk -F "=" '{print $2}' | sed -e 's/^[[:space:]]*//'
}
export -f _get_value

