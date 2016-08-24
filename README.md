# CLI Docker image for Drupal

## Includes

- PHP-CLI 5.5.22
- Composer
- Drush 7
- Drupal Console
- Ruby 1.9.3 + Gem 1.8.11
- Bundler 1.8.5
- NodeJS 0.12.0 + NPM 2.5.1
- Grunt 0.1.13
- Bower 1.3.12
- Python 2.7.3

Also:

- git
- wget
- zip
- mysql-client
- gosu

Added folder to startup.sh to allow for Drush overrides by the local development environment. This is needed as to run drush sql-sync one alias must be local and different alias settings are need when running on the host compared to the container.
