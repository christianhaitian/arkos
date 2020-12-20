#!/bin/bash
/usr/local/bin/solarushotkeydemon.py &
killlater=$!
cd /opt/solarus/
/opt/solarus/solarus-run "$1"
kill $killlater