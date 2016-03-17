#!/bin/bash

# Default SSH key name
if [ -z $SSH_KEY_NAME ]; then SSH_KEY_NAME='id_rsa'; fi
echo "Using SSH key name: $SSH_KEY_NAME"

# Copy SSH key pairs.
# @param $1 path to .ssh folder
copy_ssh_key (){
  local path="$1/$SSH_KEY_NAME"
  if [ -f $path ]; then
    echo "Copying SSH key $path from host..."
    cp $path ~/.ssh/$SSH_KEY_NAME
    cp ${path}.pub ~/.ssh/$SSH_KEY_NAME.pub
    chmod 600 ~/.ssh/$SSH_KEY_NAME
    chmod 644 ~/.ssh/$SSH_KEY_NAME.pub
  fi
}

# Copy Acquia Cloud API credentials
# @param $1 path to the home directory (parent of the .acquia directory)
copy_dot_acquia (){
  local path="$1/.acquia/cloudapi.conf"
  if [ -f $path ]; then
    echo "Copying Acquia Cloud API settings in $path from host..."
    mkdir -p ~/.acquia
    cp $path ~/.acquia
  fi
}

# Copy Drush settings from host
# @param $1 path to the home directory (parent of the .drush directory)
copy_dot_drush (){
  local path="$1/.drush"
  if [ -d $path ]; then
    echo "Copying Drush settings in $path from host..."
    cp -r $path ~
  fi
}

# Copy bash configuration files from artificial $HOME in docker environment
# @param $1 path to the home directory (parent of the .drush directory)
copy_dot_bash (){
  local path="$1/"
  if [ -d $path ]; then
    echo "Copying Bash settings in $path from artificial \$HOME directory..."
    cp -r $path/. ~
  fi
}
# Copy authorized_keys from docker host.
copy_authorized_keys (){
   local path="$1/authorized_keys"
  if [ -f $path ]; then
    echo "Copying $path from host..."
    cp $path ~/.ssh/authorized_keys
  fi 
}

# Copy SSH keys from host if available
copy_ssh_key '/.home/.ssh' # Generic
copy_ssh_key '/.home-linux/.ssh' # Linux (docker-compose)
copy_ssh_key '/.home-b2d/.ssh' # boot2docker (docker-compose)

# Copy Acquia Cloud API credentials from host if available
copy_dot_acquia '/.home' # Generic
copy_dot_acquia '/.home-linux' # Linux (docker-compose)
copy_dot_acquia '/.home-b2d' # boot2docker (docker-compose)

# Copy Drush settings from host if available
copy_dot_drush '/.home' # Generic
copy_dot_drush '/.home-linux' # Linux (docker-compose)
copy_dot_drush '/.home-b2d' # boot2docker (docker-compose)
copy_dot_drush '/.home-localdev'   # Drush overrides from local environment home folder

# Copy Bash settings from artificial $HOME folder if available
copy_dot_bash '/.home-localdev'
cp  /.home-localdev/{.b,.dr,.p}*  ~ 2>/dev/null 

# Copy scripts from artificial $HOME folder if available
cp  /.home-localdev/bin/*  ~/bin/ 2>/dev/null

# Copy authorized_keys from docker projects home folder.
# Place your authorized_keys file one folder below the project folders.
# There is a link to this folder which will be copied into the container.
# symlink to ../../../authorized_keys  is located at
# <docker_projects_home_folder>/<projectname>/.home-localdev/.ssh/authorized_keys
# so this links to the authorized_keys file in the <docker_projects_home_folder>.
copy_authorized_keys '/.home-localdev/.ssh'

echo "PHP5-FPM with environment variables"
# Update php5-fpm with access to Docker environment variables
ENV_CONF=/etc/php5/fpm/pool.d/env.conf
echo '[www]' > $ENV_CONF
for var in $(env | awk -F= '{print $1}'); do
	# Skip empty/bad variables as this will blow up PHP FPM.
	if [[ ${!var} == '' || ${var} == '_' ]]; then
		echo "Skipping empty/bad variable: ${var}"
	else
		echo "Adding variable: ${var} = ${!var}"
		echo "env[${var}] = ${!var}" >> $ENV_CONF
	fi
done

# Execute passed CMD arguments
exec "$@"
