# CyberArk Conjur Secret Fetcher

GitHub Action for secure secrets delivery to your workflow test environment using CyberArk Conjur.

## Example

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
          secrets: db/sqlusername | sql_username; db/sql_password
      # ...
```

## Arguments

### Required

* `url` - this is the path to your Conjur instance endpoint.  e.g. `https://conjur.cyberark.com:8443`
* `account` - this is the account configured for the Conjur instance during deployment.
* `host_id` - this is the Host ID granted to your application by Conjur when created via policy. e.g. `host/db/github_action`
* `api_key` - this is the API key associated with your Host ID declared previously.
* `secrets` - a semi-colon delimited list of secrets to fetch.  Refer to [Secrets Syntax](#secrets-syntax) in the README below for more details.

### Optional

* `certificate` - if using a self-signed certificate, provide the contents for validated SSL.

## Secrets Syntax

The `secrets` argument is a semi-colon (`;`) delimited list of secrets. The list can optionally contain the name to set for the environment variable.

`db/sqlusername | sql_username; db/sql_password`

In the above example, the first secret section is `db/sqlusername | sql_username`.  The `|` separates the Conjur Variable ID from the environment variable name to set the value to.  The Secret Fetcher action will UPPERCASE all environment variables before setting.

The second secret section is `db/sql_password`.  When no name is given for the environment variable, the Conjur Variable Name will be used.  In this example, the value would be set to `SQL_PASSWORD` as the environment variable name.

## Security

### Protecting Arguments

It is recommended to set the URL, Host ID, and API Key values for the Action to function as secrets by going to Settings > Secrets in your GitHub repository and adding them there.  These can then be called in your workflows' YAML file as a variable: `${{ secrets.SECRETNAME }}`

### Masking

The CyberArk Conjur Secret Fetcher GitHub Action utilizes masking prior to setting secret values to the environment.  This prevents output to the console and to logs.

## License

[MIT](LICENSE)
