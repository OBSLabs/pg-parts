#!/bin/bash

# ugly hack
/etc/init.d/cron start
sleep 10
cp /virool/app/pgparts_cron /etc/cron.d/pgparts_cron
sleep infinity
