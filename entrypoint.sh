#!/bin/bash
# Conjur Secret Retrieval for GitHub Action conjur-action

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf "%%20" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

# URL-encode Host ID for future use
hostId=$(urlencode "$3")

# If certificate input is not empty...
if [[ -n "$6" ]]; then
    # Create conjur_account.pem for valid SSL
    echo "$6" > conjur_"$2".pem

    # Authenticate and receive session token from Conjur - encode Base64
    token=$(curl --cacert conjur_"$2".pem --data "$4" "$1"/authn/"$2"/"$hostId"/authenticate | base64 | tr -d '\r\n')

    # Iterate through secrets parsing...
    # Secrets Example: db/sqlusername | sql_username; db/sql_password
    IFS=';'
    read -ra SECRETS <<< "$5" # [0]=db/sqlusername | sql_username [1]=db/sql_password

    for secret in "${SECRETS[@]}"; do
        IFS='|'
        read -ra METADATA <<< "$secret" # [0]=db/sqlusername [1]=sql_username

        if [[ "${#METADATA[@]}" == 2 ]]; then
            secretId=$(urlencode "${METADATA[0]}")
            envVar=${METADATA[1]^^}
        else
            secretId=${METADATA[0]}
            IFS='/'
            read -ra SPLITSECRET <<< "$secretId" # [0]=db [1]=sql_password
            arrLength=${#SPLITSECRET[@]} # Get array length
            lastIndex=$((arrLength-1)) # Subtract one for last index
            envVar=${SPLITSECRET[$lastIndex]^^}
        fi

        secretVal=$(curl --cacert conjur_"$2".pem -H "Authorization: Token token=\"$token\"" "$1"/secrets/"$2"/variable/"$secretId")

        echo ::add-mask::"${secretVal}" # Masks the value in all logs & output
        echo ::set-env name="${envVar}"::"${secretVal}" # Set environment variable
    done

    IFS=' '
# Else certificate input is empty...
else
    # Authenticate and receive session token from Conjur - encode Base64
    token=$(curl -k --data "$4" "$1"/authn/"$2"/"$hostId"/authenticate | base64 | tr -d '\r\n')

    # Iterate through secrets after parsing...
    # Secrets Example: db/sqlusername | sql_username; db/sql_password
    IFS=';'
    read -ra SECRETS <<< "$5" # [0]=db/sqlusername | sql_username [1]=db/sql_password

    for secret in "${SECRETS[@]}"; do
        IFS='|'
        read -ra METADATA <<< "$secret" # [0]=db/sqlusername [1]=sql_username

        if [[ "${#METADATA[@]}" == 2 ]]; then
            secretId=$(urlencode "${METADATA[0]}")
            envVar=${METADATA[1]^^}
        else
            secretId=${METADATA[0]}
            IFS='/'
            read -ra SPLITSECRET <<< "$secretId" # [0]=db [1]=sql_password
            arrLength=${#SPLITSECRET[@]} # Get array length
            lastIndex=$((arrLength-1)) # Subtract one for last index
            envVar=${SPLITSECRET[$lastIndex]^^}
        fi

        secretVal=$(curl -k -H "Authorization: Token token=\"$token\"" "$1"/secrets/"$2"/variable/"$secretId")

        echo ::add-mask::"${secretVal}" # Masks the value in all logs & output
        echo ::set-env name="${envVar}"::"${secretVal}" # Set environment variable
    done

    IFS=' '
fi
