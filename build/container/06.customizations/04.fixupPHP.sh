#!/bin/bash

source "${TOOLS}/php_definitions"

[ -d "${SESSIONS_DIR}" ]           || mkdir -p "${SESSIONS_DIR}"
[ -d "$RUN_DIR" ]                  || mkdir -p "$RUN_DIR"

declare iniFile=/etc/php5/php.ini
sed -i "s|^.*date.timezone =.*$|date.timezone = ${TZ}|" "$iniFile"
sed -i "s|^.*session.save_path =.*$|session.save_path = \"${SESSIONS_DIR}\"|" "$iniFile"
