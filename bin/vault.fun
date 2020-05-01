:<<\_c
. $PICASSO/core/bin/vault.fun
_c


FED_ROLE=$(echo $FED_PQDN | sed 's|\.|-|g')


:<<\_s
# guest:cli
vault write ${FED_PQDN}/issue/$FED_ROLE common_name="test.${FED_PQDN}" ttl="24h"
_s

:<<\__c
_vault_issue <server name> [ttl]  # <- $KEY, $CRT, $CHAIN -> ${!KEY}, ${!CRT}, ${!CHAIN}

_vault_issue mysub 24h  # <- $KEY, $CRT, $CHAIN
__c

function _vault_issue() {

local subdomain=$1
local ttl=${2:-24h}

curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
  -d "{\"common_name\": \"${subdomain}.${FED_PQDN}\", \"ttl\": \"$ttl\"}" \
  $VAULT_ADDR/v1/$FED_PQDN/issue/$FED_ROLE \
  | tee \
    >(jq -r .data.private_key > $KEY) \
    >(jq -r .data.certificate > $CRT) \
    >(jq -r '.data.ca_chain | .[]' > $CHAIN) \
    >/dev/null
:<<\_x
    >(jq -r .data.issuing_ca > ${prefix}_ca.crt) \
_x

:<<\_x
openssl verify -CAfile $CA_CRT ${!CHAIN}
_x
}
