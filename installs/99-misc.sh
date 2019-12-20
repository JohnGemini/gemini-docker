#!/bin/bash

install -D -d -m 775 -o www-data -g www-data /var/log/gemini

# Logrotate for Celery
cat <<EOF > /etc/logrotate.d/celery
/var/log/gemini/celery-worker.log {
        weekly
        missingok
        size 100M
        rotate 9
        notifempty
        copytruncate
}
EOF

# edit crontab to check celery process every minute
cat <<EOF > /etc/cron.d/celery
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#* * * * *    root  cd /usr/share/gocloud && python celery_manage.py check worker
#* * * * *    root  cd /usr/share/gocloud && python celery_manage.py check beat
#* * * * *    root  cd /usr/share/gocloud/Tool && python detector.py > /dev/null 2>&1

# 0 * * * *    root  cd /usr/share/gocloud/Tool && python report.py >> /var/log/gemini/report.log 2>&1
# 5 * * * *    root  cd /usr/share/gocloud/Tool && python NATreport.py >> /var/log/gemini/NATreport.log 2>&1
EOF
