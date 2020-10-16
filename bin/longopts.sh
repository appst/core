#####
#__c
#. $ROOT_PICASSO/core/bin/longopts.sh --test=TEST
#. $ROOT_PICASSO/core/bin/longopts.sh create --dproj=dhcp
#. $ROOT_PICASSO/core/bin/longopts.sh --dproj=dhcp create
#
##_debug "${!longopts[@]}"
#__c
#####

#_debug "longopts $@"

# marshal commandline arguments/values into the bash array: longopts
declare -A longopts=()

optspec=":v-:"  # ':' - leading colon turns on silent error reporting, 'v' first so DEBUG is set early, trailing ':' means to expect a parameter

#_debug3 "@ $@"

other=()

if [[ -z "$@" ]]; then

while getopts "$optspec" OPTCHAR; do

#_debug3 "longopts getopts: $getopts"

  case "${OPTCHAR}" in
    v)
            export DEBUG=1
      ;;

    -)
#_debug3 "OPTCHAR: ${OPTCHAR}"
#_debug3 "OPTARG:  ${OPTARG[*]}"
#_debug3 "OPTIND:  ${OPTIND[*]}"

# is there a value assigned to it '='
if [[ "$OPTARG" =~ '=' ]]; then

      val=${OPTARG#*=}
      opt=${OPTARG%=$val}
#_debug3 "opt: $opt, val: $val"

      if [[ "$val" == "$OPTARG" ]]; then

        # no equal sign
        opt=${OPTARG}
        val="${!OPTIND}"
        OPTIND=$(( $OPTIND + 1 ))
      else

        # equal sign
        opt=${OPTARG%=$val}
      fi

#_debug3 "--${OPTARG}" " " "${val}"

      longopts[${opt}]=${val}
else
      longopts[${OPTARG}]=""
fi
      ;;

    *)
#_debug3 "other option OPTARG: $OPTARG"
other+=("$OPTARG")
#continue
#      if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
#        _alert "Undefined argument: '-${OPTARG}'"
#        >&2 echo "$0 usage:" && grep "[[:space:]].)\ #" $0 | sed 's/#//' | sed -r 's/([a-z])\)/-\1/';
#        exit 1;
#      fi
      ;;

    esac

shift
done

else

# options are contained in $@

#_debug "longopts IFS: $IFS, @: $@"

for OPTARG in "$@"; do

#_debug "longopts OPTARG: $OPTARG"

  case "${OPTARG}" in
    -v)
            export DEBUG=1
      ;;

    --) break;;

    --*)
#_debug "OPTARG:  ${OPTARG[*]}"
#_debug "OPTIND:  ${OPTIND[*]}"

      OPTARG="${OPTARG:2}"  # remove '--'

# is there a value assigned to it '='
if [[ "$OPTARG" =~ '=' ]]; then

      val=${OPTARG#*=}  # split on '='
      opt=${OPTARG%=$val}
#_debug3 "opt: $opt, val: $val"

      if [[ "$val" == "$OPTARG" ]]; then

        # no equal sign found

        _alert "Undefined argument: '-${OPTARG}'"
        echo "do you mean: --${OPTARG}=<value>"
        break
      fi

#_debug "--${OPTARG}" " " "${val}"

      longopts[${opt}]=${val}
else
      longopts[${OPTARG}]=""
fi
      ;;

    *)
#_debug3 "other option OPTARG: $OPTARG"
other+=("$OPTARG")
#continue
#      longopts[${OPTARG}]=""
      ;;

    esac

shift
done

fi

#echo ${other[@]}

set -- "${other[@]}" # restore other parameters
#set --  # clear script arguments to prevent re-entry and parameter propagation to sourced sub-scripts

#####
#__s
#[[ -n $DEBUG ]] && {
#  echo -e "\e[01;32m${BASH_SOURCE[0]}:${LINENO} DEBUG=$DEBUG -> /etc/environment\e[0m"
#  cat <<< "DEBUG=$DEBUG" >> /etc/environment
#}
#__s
#####
