#!/bin/bash
sudo chown -R www-data: /usr/share/gocloud
rm -rf /usr/share/gocloud/uploaded_files/*

# patch settings.py with environment variables
sed -i -r "/DATABASES/,/^}/{/default/,/}/{s/(USER':.*)'(.*)'/\1'${MYSQL_USERNAME:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/default/,/}/{s/(PASSWORD':.*)'(.*)'/\1'${MYSQL_PASSWORD:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/default/,/}/{s/(HOST':.*)'(.*)'/\1'${MYSQL_HOSTNAME:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/default/,/}/{s/(NAME':.*)'(.*)'/\1'${MYSQL_DB:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/default/,/}/{s/(PORT':[^0-9]*)([0-9]+)/\1${MYSQL_PORT:-\2}/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/slurm/,/}/{s/(USER':.*)'(.*)'/\1'${SLURM_USERNAME:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/slurm/,/}/{s/(PASSWORD':.*)'(.*)'/\1'${SLURM_PASSWORD:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/slurm/,/}/{s/(HOST':.*)'(.*)'/\1'${SLURM_HOSTNAME:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/slurm/,/}/{s/(NAME':.*)'(.*)'/\1'${SLURM_DB:-\2}'/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "/DATABASES/,/^}/{/slurm/,/}/{s/(PORT':[^0-9]*)([0-9]+)/\1${SLURM_PORT:-\2}/}}" /usr/share/gocloud/gocloud/settings.py
sed -i -r "s/amqp:\/\/(.*):(.*)@(.*):(.*)\//amqp:\/\/${AMQP_USERNAME:-\1}:${AMQP_PASSWORD:-\2}@${AMQP_HOSTNAME:-\3}:${AMQP_PORT:-\4}\//" /usr/share/gocloud/gocloud/settings.py

if [ "${SERVICE}" == "worker" -o "${SERVICE}" == "beat" ]; then
    if [ "${SERVICE}" == "worker" ]; then
        python celery_manage.py start ${SERVICE} && \
        sudo sed -i -r "s/^#(.*detector.*)/\1/" /etc/cron.d/celery || exit 1
    else
        sudo supervisord -c /beat-supervisord.conf || exit 1
    fi
    sudo sed -i -r "s/^#(.*${SERVICE})/\1/" /etc/cron.d/celery
elif [ "${SERVICE}" == "apache2" ]; then
    while ! mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -h${MYSQL_HOSTNAME} -P${MYSQL_PORT} -e 'status'
    do
        sleep 10
    done
    sudo supervisord -c /apache-supervisord.conf || exit 1
fi
[ $? == 0 ] && bash -c "$@" || exit 1
