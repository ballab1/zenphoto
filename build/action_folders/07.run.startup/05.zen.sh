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


chown "${WWW_UID}:$WWW_GID" -R /var/log
chown "${WWW_UID}:$WWW_GID" -R "${WWW}"

find "${WWW}" -type d -exec chmod 755 {} \;
find "${WWW}" -type f -exec chmod 444 {} \;

cd "${ZEN_DIR}/zp-data"
for file in  .htaccess charset_* *.jpg ; do
    [ ! -e "$file" ] || chmod 444 $file
done
for file in  setup.log security.log zenphoto.cfg.* ; do
    [ ! -e "$file" ] || chmod 600 "$file"
done

chmod 755 "${ZEN_DIR}/zp-data"