#!/bin/bash
sudo chown -R www-data: /usr/share/gocloud
sudo rm -rf /usr/share/gocloud/uploaded_files/*
if [ "${SERVICE}" == "worker" -o "${SERVICE}" == "beat" ]; then
    while [ ! -f initialized ]
    do
        sleep 10
    done
    if [ "${SERVICE}" == "worker" ]; then
        python celery_manage.py start ${SERVICE} && \
        sudo sed -i -r "s/^#(.*detector.*)/\1/" /etc/cron.d/celery || exit 1
    else
        if ! grep beat /supervisord.conf; then
            cat <<EOF | sudo tee -a /supervisord.conf

[program:beat]
command=python manage.py celery beat --loglevel=info --logfile=/var/log/gemini/celery-beat.log
numprocs=1
autostart=true
autorestart=true
stopsignal=INT
EOF
        fi
        sudo supervisord -c /supervisord.conf || exit 1
    fi
    sudo sed -i -r "s/^#(.*${SERVICE})/\1/" /etc/cron.d/celery
elif [ "${SERVICE}" == "apache2" ]; then
    while ! mysql -uroot -p${MYSQL_ROOT_PASSWORD} -hmysql -e 'status'
    do
        sleep 10
    done
    if ! grep apache /supervisord.conf; then
        cat <<EOF | sudo tee -a /supervisord.conf

[program:apache_exporter]
command=apache_exporter
numprocs=1
autostart=true
autorestart=true
stopsignal=INT

[program:apache2]
command=apache2ctl -D FOREGROUND
numprocs=1
autostart=true
autorestart=true
stopsignal=INT
EOF
    fi
    sudo supervisord -c /supervisord.conf || exit 1
    if [ ! -f initialized ]; then
        python init.py && touch initialized
    fi
fi
[ $? == 0 ] && bash -c "$@" || exit 1
