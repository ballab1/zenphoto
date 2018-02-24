#!/bin/bash

source "${CBF['action']}/php_definitions"

chown nobody:nobody -R "$SESSIONS_DIR"
chown nobody:nobody -R "$RUN_DIR"
