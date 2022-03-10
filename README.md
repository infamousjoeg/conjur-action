# CyberArk Conjur Secret Fetcher

GitHub Action for secure secrets delivery to your workflow test environment using CyberArk Conjur.

Supports authenticating with CyberArk Conjur using host identity and JWT authentication.

[![](https://github.com/infamousjoeg/conjur-action/workflows/conjur-action%20Test/badge.svg)](https://github.com/infamousjoeg/conjur-action/actions?workflow=conjur-action+Test)



## Host Identity

### Example

```yaml
on: [push]

jobs:
  test:
    # ...
    steps:
      # ...
      - name: Import Secrets using CyberArk Conjur Secret Fetcher
        uses: infamousjoeg/conjur-action
        with:
          url: ${{ secrets.CONJUR_URL }}
          account: cyberarkdemo
          host_id: ${{ secrets.CONJUR_USERNAME }}
          api_key: ${{ secrets.CONJUR_API_KEY }}
          secrets: db/sqlusername|sql_username;db/sql_password
      # ...
```

### Arguments

#### Required

* `url` - this is the path to your Conjur instance endpoint.  e.g. `https://conjur.cyberark.com:8443`
* `account` - this is the account configured for the Conjur instance during deployment.
* `host_id` - this is the Host ID granted to your application by Conjur when created via policy. e.g. `host/db/github_action`
* `api_key` - this is the API key associated with your Host ID declared previously.
* `secrets` - a semi-colon delimited list of secrets to fetch.  Refer to [Secrets Syntax](#secrets-syntax) in the README below for more details.

#### Optional

* `certificate` - if using a self-signed certificate, provide the contents for validated SSL.

#### Not required
* `authn_id` - this is the ID of Authn-JWT at Conjur




## JWT Authentication

### Example

```yaml
on: [push]

jobs:
  test:
    # ...
    permissions:
      id-token: 'write'
      contents: 'read
    steps:
      # ...
      - name: Import Secrets using CyberArk Conjur Secret Fetcher
        uses: infamousjoeg/conjur-action@master
        with:
          url: ${{ secrets.CONJUR_URL }}
          account: cyberarkdemo
          authn_id: ${{ secrets.CONJUR_AUTHN_ID }}
          secrets: db/sqlusername|sql_username;db/sql_password
      # ...
```

### Conjur Setup

JWT Authenticator is required at Conjur server.  You may wish to refer to [official doc](https://docs.cyberark.com/Product-Doc/OnlineHelp/AAM-DAP/Latest/en/Content/Operations/Services/cjr-authn-jwt.htm?tocpath=Integrations%7CJWT%20Authenticator%7C_____0) 

The sample policy below validates GitHub repository & workflow

1. [Sample authenticator policy](github-authn-jwt.yml)
2. [Sample app id policy](github-app-id.yml)
3. Sample secret values and commands:
```
conjur policy load -f ./policy/github-authn-jwt.yml -b root
conjur policy load -f ./policy/github-app-id.yml -b root

conjur variable set -i conjur/authn-jwt/github/issuer -v "https://token.actions.githubusercontent.com"
conjur variable set -i conjur/authn-jwt/github/jwks-uri -v "https://token.actions.githubusercontent.com/.well-known/jwks"
conjur variable set -i conjur/authn-jwt/github/token-app-property -v "workflow"
conjur variable set -i conjur/authn-jwt/github/enforced-claims -v "workflow,repository"
conjur variable set -i conjur/authn-jwt/github/identity-path -v "/github-apps"
```

### Arguments

#### Required

* `url` - this is the path to your Conjur instance endpoint.  e.g. `https://conjur.cyberark.com:8443`
* `account` - this is the account configured for the Conjur instance during deployment.
* `authn_id` - this is the ID of Authn-JWT at Conjur
* `secrets` - a semi-colon delimited list of secrets to fetch.  Refer to [Secrets Syntax](#secrets-syntax) in the README below for more details.

#### Optional

* `certificate` - if using a self-signed certificate, provide the contents for validated SSL.

#### Not required
* `host_id` - this is the Host ID granted to your application by Conjur when created via policy. e.g. `host/db/github_action`
* `api_key` - this is the API key associated with your Host ID declared previously.


## Secrets Syntax

`{{ conjurVariable1|envVarName1;conjurVariable2 }}`

The `secrets` argument is a semi-colon (`;`) delimited list of secrets. Spaces are NOT SUPPORTED. The list can optionally contain the name to set for the environment variable.

### Example

`db/sqlusername|sql_username;db/sql_password`

In the above example, the first secret section is `db/sqlusername|sql_username`.  The `|` separates the Conjur Variable ID from the environment variable that will contain the value of the Conjur Variable's value.

The second secret section is `db/sql_password`.  When no name is given for the environment variable, the Conjur Variable Name will be used.  In this example, the value would be set to `SQL_PASSWORD` as the environment variable name.

## Security

### Protecting Arguments

It is recommended to set the URL, Host ID, and API Key values for the Action to function as secrets by going to Settings > Secrets in your GitHub repository and adding them there.  These can then be called in your workflows' YAML file as a variable: `${{ secrets.SECRETNAME }}`

### Masking

The CyberArk Conjur Secret Fetcher GitHub Action utilizes masking prior to setting secret values to the environment.  This prevents output to the console and to logs.

## Maintainer

Joe Garcia - [@infamousjoeg](https://github.com/infamousjoeg)

Quincy Cheng - [@quincycheng](https://github.com/quincycheng)

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

[buymeacoffee]: https://www.buymeacoffee.com/infamousjoeg
[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png

## License

[MIT](LICENSE)
