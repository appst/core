:<<\_c
. $PICASSO/core/bin/nics.fun
# _PNICS_2array
# compound alias and function - the array must be declared via the alias and then passed by reference to the function
# NB: arrays must exist outside of functions - they cannot be created in a function then inherited by script outside that function
# therefore, we declare the array within an alias which then calls a complementary function for additional processing
# NB: we are dealing with one dimensional arrays - that's all bash has
_c


# ----------
alias _PNICS_2array='cnics_length=0; for nic in $PNICS; do cnics_length=$((cnics_length+1)); v=cnics${cnics_length}; eval "declare -a $v=(${nic//:/ })"; _PNICS_2array2 $v; done'

function _PNICS_2array2() {
local -n v=$1
local IPx=${v[0]}
local IP=${IPx%-*}  # retain the part before the first hyphen (IP1)
local ip=${IPx#*-}  # retain the part after the first hyphen (1.2.3.4)
#_debug "$IP: $ip"
[[ -n "$ip" ]] && export $IP=$ip
}


# ----------
:<<\_c
_PNICS_2stdout PNICS ?
_c

function _PNICS_2stdout() {  # <array prefix> <variable prefix>
local ptr_length=${1}_length  # ptr_length=PNICS_length
local i

for ((i=1;i<=${!ptr_length};i++)); do

#_debug "_PNICS_2env $1 $2 $i"
_PNICS_2env $1 $2 $i

local IP=${2}_IP
local ip=${2}_ip
local mnemonic=${2}_mnemonic
local type=${2}_type
local option1=${2}_option1

#_debug "mnemonic: $mnemonic, IP: $IP, ip: $ip, type: $type, options: $options"

printf "${1}${i}: %s, %s, %s %s %s\n" ${!IP} ${!ip} ${!mnemonic} ${!type} ${!option1}
done
}


# ----------
function _PNICS_2env() {
local i=$3

local IPx=${1}${i}[0]  # IPx=cnics1[0]
#_debug "$i - IPx: $IPx"
IPx=${!IPx}  # IPx=IP1-192.168.1.5
#_debug "$i - IPx: $IPx"

local IP=${IPx%-*}  # retain the part before the first hyphen (IP1)
export ${2}_IP=$IP

local ip=${IPx#*-}  # retain the part after the first hyphen (MNIC_IP/controller.domain.com/1.2.3.4)
[[ $ip =~ _IP$ ]] && ip=${!ip}  # ends with '_IP'
export ${2}_ip=$ip

local mnemonic=${1}${i}[1]  # mnenmonic=cnics1[1]
export ${2}_mnemonic=${!mnemonic}  # cnics_menmonic=MNIC

local type=${1}${i}[2]  # type=cnics1[2]
export ${2}_type=${!type}  # cnics_menmonic=MNIC

local option1=${1}${i}[3]  # option1=cnics1[3]
export ${2}_option1=${!option1}  # cnics_option1=intnet-tunnel
}


# ----------
:<<\_x
. $PICASSO/core/bin/nics.sh

PNICS=" \
  IP1-$IDENTITY_MANAGEMENT_IP:MNIC:intnet-management \
  IP2-$NETWORK_EXTERNAL_IP:XNIC:bridged:provider-flat \
  IP3-$NETWORK_TUNNEL_IP:TNIC:bridged"

_PNICS_2array  # -> env:cnics${i}[<1...4>], cnics_length
_PNICS_2stdout cnics cnic  # <- env:cnics_length
_PNICS_2env cnics cnic 1  # -> env:cnic_{?}
env | grep cnic
_x


# ----------
:<<\__c
_PNICS_2setenv cnics cnic

marshal array into environment values for pconfig...
export ip1
export class_c1
export netmask1
export prefix1
export broadcast1
export network1
export gateway1
export mode1
export cidr1
__c

function _PNICS_2setenv() {
local ptr_length=${1}_length
local i

_debug "_PNICS_2setenv ptr_length: ${!ptr_length}"

#(( DEBUG > 0 )) && printf "\n#---> dynamically generated from: $(readlink --canonicalize $BASH_SOURCE)\n" >> $PROVIDER_ENV

#cat >> $PROVIDER_ENV <<!
#export NICS=
#!

for ((i=1;i<=${!ptr_length};i++)); do

_debug2 "_PNICS_2env $1 $2 $i"

_PNICS_2env $1 $2 $i  # -> env:cnic_{?}

_debug3 "$(env | grep ${2}_)"

_debug2 "$n) cnic_IP: $cnic_IP, cnic_ip: $cnic_ip, cnic_mnemonic: $cnic_mnemonic, cnic_type: $cnic_type, cnic_option1: $cnic_option1"

# IP1 - extract the last character that is the interface offset
local IP=${2}_IP
n=${!IP: -1}  # nic1

local mnemonic=${2}_mnemonic
mnemonic=${!mnemonic}
export $mnemonic=nic${n}  # MNIC=nic1

_C=${mnemonic}_C  # from env.sh(cookbook)
[[ -z "${!_C}" ]] && _alert "-z \$${mnemonic}_C"  # insure environment exists
_NETMASK=${mnemonic}_NETMASK
_PREFIX=${mnemonic}_PREFIX
_BROADCAST=${mnemonic}_BROADCAST
_NETWORK=${mnemonic}_NETWORK
_GATEWAY=${mnemonic}_GATEWAY
_MODE=${mnemonic}_MODE

_debug2 "export mnemonic${i}=$mnemonic"

export mnemonic${i}=$mnemonic  # -> create-vagrantfile.sh

export class_c${i}=${!_C}
export netmask${i}=${!_NETMASK}
export prefix${i}=${!_PREFIX}
export broadcast${i}=${!_BROADCAST}
export network${i}=${!_NETWORK}
export gateway${i}=${!_GATEWAY}
export mode${i}=${!_MODE}
export cidr${i}=${!_NETWORK}/${!_PREFIX}

local ip=${2}_ip
export ip${n}=${!ip:-${!_C}.254}  # ip1=x.x.x.x

#_debug "glsoeutgso ${2}_ip: ${!ip}, _C: $_C"
#_debug "glsoeutgso export ip${n}=${!ip:-${!_C}.254}"

#cat >> $PROVIDER_ENV <<!
#export $mnemonic=nic${n}
#export NICS+=" $mnemonic"
#!

_ADAPTER=ADAPTER${n}  # _ADAPTER=ADAPTER1

_debug2 "$_ADAPTER: ${!_ADAPTER}"

[[ -z "${!_ADAPTER}" ]] && {
x=${HOSTNAME^^}_${mnemonic}_ADAPTER
export ADAPTER${n}="${!x}"  # ADAPTER1="${!SKYLAKE_MNIC_ADAPTER}"
_debug2 "export ADAPTER${n}=\"${!x}\""
}

#_debug "$_ADAPTER: ${!_ADAPTER}"

done


#(( DEBUG > 0 )) && printf "#<--- dynamically generated from: $(readlink --canonicalize $BASH_SOURCE)\n" >> $PROVIDER_ENV

}
