
:<<\_c
bootstrap --help  # -v ${longopts[help]}, ${!longopts[help]} NOT DEFINED
bootstrap --help=command  # -v ${longopts[help]}, ${!longopts[help]}=command
bootstrap help  # $@ == 'help'
_c


----------
# longopts replaces this...

while [[ "$#" > 0 ]]; do
  case $1 in
    --home=*) PSOURCE="${1#*=}";;
    --provisioner=*) PROVISIONER="${1#*=}";;
    --clone=*) copy="${1#*=}";;
    --follow=*) follow="${1#*=}";;
    *) break;;
  esac
shift
done

----------
# test - works with empty assignments
. $OPT_PICASSO/core/bin/longopts.sh --test=1 --test2= --test3=3
for opt in "${!longopts[@]}"; do  # keys
val=${longopts[$opt]}
echo "opt: $opt, val: $val"
done
  opt: test2, val:
  opt: test3, val: 3
  opt: test, val: 1


:<<\_x
function testenv() {

. $PICASSO/core/bin/longopts.sh

for opt in "${!longopts[@]}"; do  # keys
val=${longopts[$opt]}
case $opt in
provisioner-env)
_info "Environment: $val"
PROVISIONER_ENV=$val
_debug3 "$(cat $val)"
;;
esac
done
}

testenv /service/aggregate2 --opt=f0 --provisioner-env=<(cat <<!
DOMAINS="$DOMAINS"
!
)
_x
