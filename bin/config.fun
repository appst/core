:<<\_c
insert after a [section] in a file - if the section does not exist then is is appended to the end of the file

. $PICASSO/core/bin/config.fun

_section_insert <section> <file> <<EOF
multi-line
multi-line
EOF

_section_insert <section> <file> <<< "line"

_section_insert 'database' /etc/keystone/keystone.conf <<< "connection=mysql://$keystone_DBUSER:$keystone_DBPASS@$HOSTDB/$keystone_DBNAME"

_section_insert 'keystone_authtoken' /etc/glance/glance-api.conf <<EOF
auth_uri=http://keystone:5000/v2.0
identity_uri=http://keystone:35357
admin_tenant_name=service
admin_user=$glance_OSNAME
admin_password=$glance_OSPASS
auth_version = v${OS_IDENTITY_API_VERSION}
EOF

# NB: leave the blank line after the 'cat'
_c

function _section_insert() {
#_debug "section: $1, payload: $2"
if grep -q "^\[$1\]" $2; then  # does the section already exist?
# yes, insert data
OFS=$IFS
IFS=$'\n'
#sed -i "/^\[$1\]/ a$(while read i; do printf $i\\\\n; done)" $2
sed -i "/^\[$1\]/ a$(while read i; do printf $i; done)" $2
#sed -i "/^\[$1\]/ a$(echo '#_section_insert')" $2
IFS=$OFS
else
# no
cat <<EOF >> $2
[$1]
$(while read i; do printf "$i\\n"; done)
EOF
fi
}
#export -f _section_insert

:<<\_x
cat <<EOF >test
[SECTION1]
[SECTION2]
EOF
_section_insert 'SECTION1' test <<< "section=1"
cat test
_section_insert 'SECTION1' test <<< "section=1"
cat test
_section_insert 'SECTION2' test <<EOF
section=2
EOF
cat test
_section_insert 'SECTION2' test <<EOF
section=2
EOF
cat test
_x


# ---------- ---------- ---------- ---------- ----------
:<<\_c
sets values in configuration files (modifies or appends as necessary)
_c

function _set() {

OFS=$IFS
while IFS= read -r line
do
#    echo "$line"

IFS='=' read -ra ADDR <<< "$line"

#echo "\${#ADDR[@]}: ${#ADDR[@]}"

if [[ ${#ADDR[@]} == 0 ]]; then

:  # skip blank lines

elif [[ ${#ADDR[@]} == 1 ]]; then

_fail 'exit 2'

elif [[ ${#ADDR[@]} == 2 ]]; then

#echo "ADDR[0]: ${ADDR[0]}"
#echo "ADDR[1]: ${ADDR[1]}"

#echo _section_insert ${ADDR[0]} /etc/sysconfig/network-scripts/ifcfg-$nic1 <<< "$line"

if grep -q "^${ADDR[0]}" $2  # is it already there
then
#echo switch $line
sed -i "s/^${ADDR[0]}.*/$line/" $2  # yes, switch it
else
#echo append $line
cat <<< "$line" >> $2  # no, append it
fi

fi

done <<< "$1"
IFS=$OFS
}
#export -f _set

:<<\_x
IN="
a = aa
b=bb
"

_set "$IN" ~/t
cat ~/t
~~~
a = aa
b=bb
~~~

_set "c=cc" ~/t
cat ~/t
~~~
a = aa
b=bb
c=cc
~~~

_set "a=AA" ~/t
cat ~/t
~~~
a=AA
b=bb
c=cc
~~~
_x


# ---------- ---------- ---------- ---------- ----------
function _get() {
RET=$(grep "^$1" $2)  # get the line beginning with our target string
if [[ -z "$RET" ]]; then  # return 1 if it does not exist
return 1
fi
IFS='='  # return right side of '='
RET=$(echo $RET | awk '{print $2}')
echo $RET
return 0  # indicate target was found
}
#export -f _get

:<<\_x
RET=$(_get ONBOOT /etc/sysconfig/network-scripts/ifcfg-$nic3)
echo $RET
_x


# ---------- ---------- ---------- ---------- ----------
:<<\_c
$1 - key
$2 - value
$3 - destination
_c

function _confset() {
#echo "1: $1, 2: $2, 3: $3"

if grep -q "^$1" $3; then
sed -i "s|^$1.*|$1 $2|" $3  # change existing value
else
if grep -q "^#$1" $3; then  # uncomment and change value
sed -i "s|^#$1.*|$1 $2|" $3
else
cat <<<"$1 $2" >> $3  # append value
fi
fi
}
#export -f _confset

:<<\_x
_confset ListenAddress "0.0.0.0" /etc/ssh/sshd_config
_confset "AuthorizedKeysFile" "%h/.ssh/authorized_keys" /etc/ssh/sshd_config
_x

