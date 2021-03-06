:<<\_c
. $PICASSO/core/bin/nics.fun
# _PNICS_2array
# compound alias and function - the array must be declared via the alias and then passed by reference to the function
# NB: arrays must exist outside of functions - they cannot be created in a function then inherited by script outside that function
# therefore, we declare the array within an alias which then calls a complementary function for additional processing
# NB: we are dealing with one dimensional arrays - that's all bash has
_c
:<<\_x
. $PICASSO/core/bin/nics.fun

# PNICS=<serialized NIC values>
PNICS="IP1-192.168.1.9:MNIC:192.168.1.0 IP2-10.0.0.7:XNIC:10.0.0.0-promiscuous:provider-flat IP3-manual:TNIC:intnet-tunnel"

alias _PNICS_2array='cnics_length=0; for nic in $PNICS; do cnics_length=$((cnics_length+1)); v=cnics${cnics_length}; echo "$v: $nic"; declare -a $v=(${nic//:/ }); _PNICS_2array2 $v; done'

# marshal $PNICS into environment - $PNICS -> env:cnics${n}[0...]
_PNICS_2array

for ((i=1;i<=$cnics_length;i++)); do
_cnics=cnics${i}
for ((j=0;j<=3;j++)); do
k=$_cnics[$j]  # cnics1[0]
echo "$_cnics[$j]: ${!k}"
done
done

_PNICS_2env cnics${i} cnic

env | grep cnic_

_PNICS_dump cnics
_x

# ----------
#shopt -s expand_aliases  # 36hr bug

alias _PNICS_2array='cnics_length=0; for nic in $PNICS; do cnics_length=$((cnics_length+1)); v=cnics${cnics_length}; declare -a "$v=(${nic//:/ })"; _PNICS_2array2 $v; done'

:<<\_s
# i cannot use a function...

function z_PNICS_2array() {
cnics_length=0
for nic in $PNICS; do
cnics_length=$((cnics_length+1))
v=cnics${cnics_length}
echo "declare -a $v=(${nic//:/ })"
#eval "declare -a $v=(${nic//:/ })"
declare -a "$v=(${nic//:/ })"  # this is the problem - i cannot return an array from a function
_PNICS_2array2 $v
done
}

declare -a cnics1; z_PNICS_2array cnic cnics1
_PNICS_2setenv cnics
_s

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
dump all array content: cnics[0]... cnics[n]
we pass the array prefix: cnics
_c

function _PNICS_dump() {  # <array prefix>
local ptr_length=${1}_length  # ptr_length=PNICS_length

[[ -z "${!ptr_length}" ]] && {
_alert "empty $1"
return 1
}

_debug "ptr_length: $ptr_length, {!ptr_length}: ${!ptr_length}"
local i

for ((i=1;i<=${!ptr_length};i++)); do

_PNICS_2env dump ${1}${i}

printf "${1}${i}: %s, %s, %s %s %s\n" $dump_IP $dump_ip $dump_mnemonic $dump_type $dump_option1
done

}


# ----------
function _PNICS_2env() {  # <record name> <variable prefix>
local rec=$1
local prefix=$2

local IPx=$rec[0]  # IPx=cnics1[0]

#_debug "_PNICS_2env $@"

IPx=${!IPx}  # IPx=IP1-192.168.1.5
#_debug "$i - IPx: $IPx"

local IP=${IPx%-*}  # retain the part before the first hyphen (IP1)
export ${prefix}_IP=$IP
#_debug "export ${prefix}_IP=$IP"

local ip=${IPx#*-}  # retain the part after the first hyphen (MNIC_IP/controller.domain.com/1.2.3.4)
[[ "$ip" =~ _IP$ ]] && ip=${!ip}  # ends with '_IP'
export ${prefix}_ip=$ip
#_debug "export ${prefix}_ip=$ip"

local mnemonic=$rec[1]  # mnenmonic=cnics1[1]
export ${prefix}_mnemonic=${!mnemonic}  # cnics_menmonic=MNIC
#_debug "export ${prefix}_mnemonic=${!mnemonic}"

local type=$rec[2]  # type=cnics1[2]
export ${prefix}_type=${!type}  # cnics_menmonic=MNIC
#_debug "export ${prefix}_type=${!type}"

local option1=$rec[3]  # option1=cnics1[3]
export ${prefix}_option1=${!option1}  # cnics_option1=intnet-tunnel
#_debug "export ${prefix}_option1=${!option1}"

}


# ----------
:<<\_x
. $PICASSO/core/bin/nics.fun

PNICS=" \
  IP1-$IDENTITY_MANAGEMENT_IP:MNIC:intnet-management \
  IP2-$NETWORK_EXTERNAL_IP:XNIC:bridged:provider-flat \
  IP3-$NETWORK_TUNNEL_IP:TNIC:bridged"

_PNICS_2array  # -> env:cnics${i}[<1...4>], cnics_length
_PNICS_dump cnics  # <- env:cnics_length
_PNICS_2env cnic_1 cnics1  # -> env:cnic_{?}
env | grep cnic_1
_x


# ----------
:<<\__c
_PNICS_2setenv cnics

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

function _PNICS_2setenv() {  # <array>
local arr=$1
local ptr_length=${arr}_length

_debug2 "_PNICS_2setenv @: $@"  # cnics

[[ -z "${!ptr_length}" ]] && {
_alert "empty $1"
return 1
}

_debug2 "PNICS: $PNICS"
_debug2 "_PNICS_2setenv ptr_length: ${!ptr_length}"

local i

:<<\_c
marshal PNICS -> mnemonic1, netmask1, ip1...
PNICS is a logical array of networks
${mnemonic}_ refers to a physical adapter
cnic_mnemonic links the logical network with the physical adapter
they don't use a common index
cnic_IP=192.168.1.2
cnic_type=192.168.1.0-bridged
cnic_mnemonic=MNIC
MNIC_="Intel(R) PRO/1000 PT Quad Port LP Server Adapter #3"
_c

for ((i=1;i<=${!ptr_length};i++)); do

_debug2 "_PNICS_2env $2 $1$i"

_PNICS_2env ${arr}${i} tmp  # record -> env:tmp_{?}
:<<\_x
echo ${cnics[@]}
_PNICS_2env cnics1 tmp
env | grep tmp_
_x

_debug3 "$(env | grep ${arr}_)"

_debug2 "$n) cnic_IP: $cnic_IP, cnic_ip: $cnic_ip, cnic_mnemonic: $cnic_mnemonic, cnic_type: $cnic_type, cnic_option1: $cnic_option1"

# IP1 - extract the last character that is the interface offset
#local IP=${arr}_IP  # IP=cnic_IP
#n=${!IP:-1}  # n=nic1
#nic=${!IP:-1}  # n=nic1

#_debug2 "IP: $IP, nic: $nic"

local mnemonic=tmp_mnemonic  # mnemonic=cnic_mnemonic
mnemonic=${!mnemonic}  # mnemonic=MNIC
#export $mnemonic=nic${n}  # MNIC=nic1

_C=${mnemonic}_C  # from env.sh(cookbook)
[[ -z "${!_C}" ]] && _alert "-z \${mnemonic}_C"  # insure environment exists
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

export ip${i}=${!ip:-${!_C}.254}  # ip1=x.x.x.x

_debug2 "export ip${i}=${!ip:-${!_C}.254}"

#_debug "glsoeutgso ${arr}_ip: ${!ip}, _C: $_C"
#_debug "glsoeutgso export ip${n}=${!ip:-${!_C}.254}"

done

}
