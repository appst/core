[[ -v DEBUG && $DEBUG > 9 ]] && echo -e "\e[0;43m${BASH_SOURCE[0]}\e[m"  #]
:<<\_c
. $PICASSO/init.d/openstack/os-functions.sh
_c

:<<\_s
export IMAGE_OS=cirros
export IMAGE_NAME=cirros-0.3.5-x86_64-disk
export FLAVOR_NAME="m1.tiny"
_s
export IMAGE_OS=ubuntu
export IMAGE_NAME=picasso-server
export FLAVOR_NAME="m1.small"


# ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
# Helper function to grab a numbered field from python novaclient cli result
# Fields are numbered starting with 1
# Reverse syntax is supported: -1 is the last field, -2 is second to last, etc.
function get_field () {
    while read data
    do
        if [ "$1" -lt 0 ]; then
            field="(\$(NF$1))"
        else
            field="\$$(($1 + 1))"
        fi
        echo "$data" | awk -F'[ \t]*\\|[ \t]*' "{print $field}"
    done
}
