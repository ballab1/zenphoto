#!/bin/bash

: ${WWW_UID:?"Environment variable 'WWW_UID' not defined in '${BASH_SOURCE[0]}'"}
: ${WWW_GID:?"Environment variable 'WWW_GID' not defined in '${BASH_SOURCE[0]}'"}

if [ "${ZEN_PASS_FILE:-}" ]; then
    cat << EOT > "${ZEN_DIR}/zp-data/zenphoto.mysql.password.php"
<?php
\$conf['mysql_pass'] = '$(< "$ZEN_PASS_FILE")';
?>
EOT
fi


sudo chown "${WWW_UID}:$WWW_GID" -R /var/log
sudo chown "${WWW_UID}:$WWW_GID" -R "${WWW}"

find "${WWW}" -type d ! -wholename '*zp-data*' -exec sudo chmod a+rx {} \;
find "${WWW}" -type f ! -wholename '*zp-data*' -exec sudo chmod 444 {} \;


declare ZEN_DATA="${ZEN_DIR}/zp-data"

sudo chmod 700 "${ZEN_DATA}"
sudo chmod 400 "${ZEN_DATA}/.gitignore"
sudo chmod 444 "${ZEN_DATA}/.htaccess"
sudo chmod 400 "${ZEN_DATA}/charset_"*
sudo chmod 600 "${ZEN_DATA}/security.log"
sudo chmod 600 "${ZEN_DATA}/setup.log"
sudo chmod 400 "${ZEN_DATA}/"*.jpg
sudo chmod 600 "${ZEN_DATA}/zenphoto.cfg.bak.php"
sudo chmod 600 "${ZEN_DATA}/zenphoto.cfg.php"
sudo chmod 600 "${ZEN_DATA}/zenphoto.cfg.php~master"
sudo chmod 600 "${ZEN_DATA}/zenphoto.mysql.password.php"
sudo chmod 755 "${ZEN_DATA}/.mutex"
sudo chmod 600 "${ZEN_DATA}/.mutex/cF"
sudo chmod 400 "${ZEN_DATA}/.mutex/sP"
sudo chmod 400 "${ZEN_DATA}/.mutex/zP"
