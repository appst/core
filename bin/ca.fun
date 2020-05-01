:<<\_c
. $PGUEST/core/bin/ca.fun
_c


# ----------
function _create_KEY() {

local FQDN=$1

openssl genrsa \
  -out "$CA_HOME/private/${FQDN}.key.pem" \
  2048 | tr '\n' ' '

}
#  -out "$CA_HOME/certs/${FQDN}/privkey.pem" \


# ----------
:<<\_c
since it's never a problem to have one domain in both fields (CN and SAN) but it can be a problem to have the main domain only in the CN when using SANs, it's better to have all domains present in both fields.
Since the CN only supports one domain, it's common practice to put the main domain there, and then repeat it in the SAN field along with all the additional ones.
http://apetec.com/support/GenerateSAN-CSR.htm

chrome error: (net::ERR_CERT_COMMON_NAME_INVALID)
the cert must include a Subject Alternative Name

https://stackoverflow.com/questions/43665243/invalid-self-signed-ssl-cert-subject-alternative-name-missing
_c

function _create_CSR() {

local FQDN=$1
local subj

read subj  # <- stdin -> $subj

openssl req -new \
  -key "$CA_HOME/private/${FQDN}.key.pem" \
  -out "$CA_HOME/csr/${FQDN}.csr.pem" \
  -reqexts SAN \
  -config <(cat $CA_CONFIG <(cat <<!
[ SAN ]
subjectAltName = DNS:${FQDN}
!
)) \
  -subj "$subj" | tr '\n' ' '

:<<\_x
CA_HOME=$HOME/ca
FQDN=catest.picasso.digital
CA_CONFIG=/root/ca/openssl.cnf

openssl req -new \
  -key "$CA_HOME/private/${FQDN}.key.pem" \
  -out "$CA_HOME/csr/${FQDN}.csr.pem" \
  -reqexts SAN \
  -config <(cat $CA_CONFIG \
        <(printf "\n[ SAN ]\nsubjectAltName = DNS:${FQDN}\n")) \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME Service/CN=$FQDN"

openssl x509 -req -CAserial $CA_HOME/ca.crt.srl \
  -CA $CA_CRT -CAkey $CA_KEY \
  -in $CA_HOME/csr/${FQDN}.csr.pem \
  -out $CA_HOME/certs/${FQDN}.crt.pem \
  -extfile <(cat <<!
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $FQDN
!
) \
  -days 9131

openssl req -text -noout -in $CA_HOME/csr/${FQDN}.csr.pem | grep "DNS:"

openssl x509 -text -noout -in $CA_HOME/certs/${FQDN}.crt.pem
_x
}


# ----------
function _create_CRT() {

_debug _create_CRT
local FQDN=$1

# Sign the request from Server with your Root CA

if [[ -f $CA_HOME/ca.crt.srl ]]; then

_debug _create_CRT2

openssl x509 -req -CAserial $CA_HOME/ca.crt.srl \
  -CA $CA_CRT -CAkey $CA_KEY \
  -in $CA_HOME/csr/${FQDN}.csr.pem \
  -out $CA_HOME/certs/${FQDN}.crt.pem \
  -extfile <(cat <<!
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $FQDN
!
) \
  -days 9131 | tr '\n' ' '

else

_debug _create_CRT3

openssl x509 -req -CAcreateserial \
  -CA $CA_CRT -CAkey $CA_KEY \
  -in $CA_HOME/csr/${FQDN}.csr.pem \
  -out $CA_HOME/certs/${FQDN}.crt.pem \
  -extfile <(cat <<!
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $FQDN
!
) \
  -days 9131 | tr '\n' ' '

fi

}

