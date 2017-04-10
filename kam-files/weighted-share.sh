#!/bin/bash

# shoot any scdaemons
pkill scdaemon
pkill gpg-agent

# create new masterkey and stubby keys

# display name
if [ -z "${GPG_NAME}" ] ; then GPG_NAME="RJ Bergeron" ; fi
# email
if [ -z "${GPG_EMAIL}" ] ; then GPG_EMAIL="reco@bad.id" ; fi

# subkey lengths
if [ -z "${ENCRYPTION_SUBKEY_COUNT}" ] ; then ENCRYPTION_SUBKEY_COUNT="1" ; fi

# if I don't have a master key, make one
gpg2 --list-keys "${GPG_EMAIL}"
if [ "${?}" -ne 0 ] ; then
  gpg2 --gen-key --batch << MASTER_PARAMS
%no-ask-passphrase
%no-protection
Key-Type: rsa
Key-Length: 4096
Key-Usage: cert,encrypt
Name-Real: ${GPG_NAME}
Name-Email: ${GPG_EMAIL}
Preferences: SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
${REVOKER}
MASTER_PARAMS
fi

# create unexpired encryption subkeys
while [ $(gpg2 --list-keys --with-colons "${GPG_EMAIL}" | grep "sub:u:4096" | grep -c "e::::::") != ${ENCRYPTION_SUBKEY_COUNT} ] ; do
  gpg2 --edit-key --batch --command-fd 0 --passphrase '' "${GPG_EMAIL}" << SUBKEY_PARAMS
%no-ask-passphrase
%no-protection
addkey
rsa/e
4096
0
save
SUBKEY_PARAMS
done

# so, the theory here is we'll order subkeys and load by expiry - the first export contains the last to expire
# and types s/e/a. the second blob contains the next e/a keys. the c key doesn't get exported until we backup the
# whole thing.

# track loaded keys here
loaded=""
_one=""
_two=""
one=""
two=""

for l in e ; do
_one="${_one} $(gpg2 --list-keys --with-colons "${GPG_EMAIL}" | grep "sub:u:4096" | grep "${l}::::::" |gawk -F: '{ key[$7]=$5 } END { asort(key) ; print key[1] }')"
done

for k in ${_one} ; do
  one="${one} 0x${k}!"
done

loaded="${one} ${two}"

# export the private keys to files
gpg2 --export-secret-subkeys -a ${one} > ${GPG_EMAIL}-redone.asc

rm -rf scratch
mkdir scratch
echo 'reader-port "Yubico Yubikey NEO OTP+U2F+CCID 01 00"' > scratch/scdaemon.conf
env GNUPGHOME=$(pwd)/scratch gpg2 --import "${GPG_EMAIL}-redone.asc"
env GNUPGHOME=$(pwd)/scratch gpg2 --edit-key --batch --command-fd 0 --passphrase '' "${GPG_EMAIL}" << TRUST
trust
5
y
save
TRUST

# we need to actually get the order the subkeys were written in for card writing
ekey=$(env GNUPGHOME=$(pwd)/scratch gpg2 --list-keys --with-colons 2>/dev/null | grep 'sub:u:' | grep -n ':e::::::')
ekey=${ekey:0:1}

# now that we know which key is which, push to card. you will be prompted for the admin pin.
printf '\nrun:\ntoggle\nkey %s\nkeytocard\n2\nsave\n\n' ${ekey}
env GNUPGHOME=$(pwd)/scratch gpg2 --edit-key "${GPG_EMAIL}"

# export the resulting stubby key
env GNUPGHOME=$(pwd)/scratch gpg2 --export-secret-subkeys "${GPG_EMAIL}" > ${GPG_EMAIL}-blackone.gpg

pkill scdaemon
pkill gpg-agent

# shred the previous exports
rm -P ${GPG_EMAIL}-redone.asc

pubkeys="0x$(env GNUPGHOME=$(pwd)/scratch gpg2 --list-keys --with-colons 2>/dev/null | grep 'sub:u:' | grep ':e::::::' | cut -d: -f5)!"

# now import the first key
env GNUPGHOME=$(pwd)/scratch gpg2 --import "${GPG_EMAIL}-blackone.gpg"

# and grab all the other keys
for l in $(env GNUPGHOME=$(pwd)/scratch gpg2 --list-keys --with-colons|grep 'sub:u:'|cut -d: -f5,12 | grep -E '(a|s)$') ; do
  pubkeys="${pubkeys} 0x${l%:*}!"
done

env GNUPGHOME=$(pwd)/scratch gpg2 --export -a ${pubkeys} > ${GPG_EMAIL}-upload.asc

# now assemble a legacy gpg keyring...
rm -rf one
mkdir one
( cd one && gpgsplit ../"${GPG_EMAIL}-blackone.gpg" )
cat one/* > "${GPG_EMAIL}-gpg14.gpg"
