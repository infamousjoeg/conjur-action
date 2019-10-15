#!/bin/bash
# Conjur Secret Retrieval for GitHub Action conjur-action

parse_secrets() { # example: 
    echo "TODO"
}

main() {
    # If certificate input is not empty...
    if [[ -n "$5" ]]; then
        # Create conjur_account.pem for valid SSL
        echo "$5" > conjur_"$2".pem
        # Authenticate and receive session token from Conjur - encode Base64
        token=$(curl --cacert conjur_"$2".pem --data "$4" "$1"/authn/"$2"/"$3"/authenticate | base64 | tr -d '\r\n')
        # Iterate through secrets after parsing...

    # Else certificate input is empty...
    else
        # Authenticate and receive session token from Conjur - encode Base64
        token=$(curl -k --data "$4" "$1"/authn/"$2"/"$3"/authenticate | base64 | tr -d '\r\n')
        # Iterate through secrets after parsing...
    fi
}