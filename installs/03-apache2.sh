#!/bin/bash

apt-get install -y apache2 php5 libapache2-mod-wsgi openssl ssl-cert

mkdir -p /run/lock /etc/apache2/ssl

# enable gocloud https
a2enmod ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt -subj "/C=TW/ST=Taipei/L=Taipei/O=GeminiOpenCloud/OU=GeminiPortal/CN=geminiopencloud.com"
cat <<EOF > /etc/apache2/sites-available/gocloud.conf
<VirtualHost *:443>
        ServerName 0.0.0.0:443
        ServerAlias gocloud
        DocumentRoot /usr/share/gocloud
        WSGIScriptAlias / "/usr/share/gocloud/gocloud.wsgi"
        WSGIPassAuthorization On
        Alias /static/ "/usr/share/gocloud/static/"
        <Directory "/usr/share/gocloud">
                Order deny,allow
                Allow from all
        </Directory>
      #   SSL Engine Switch:
      #   Enable/Disable SSL for this virtual host.
      SSLEngine on

      #   A self-signed (snakeoil) certificate can be created by installing
      #   the ssl-cert package. See
      #   /usr/share/doc/apache2.2-common/README.Debian.gz for more info.
      #   If both key and certificate are stored in the same file, only the
      #   SSLCertificateFile directive is needed.
      SSLCertificateFile /etc/apache2/ssl/apache.crt
      SSLCertificateKeyFile /etc/apache2/ssl/apache.key
</VirtualHost>
EOF
cat <<EOF > /etc/apache2/sites-available/gocloudapi.conf
Listen 8000

<VirtualHost *:8000>
        ServerName 0.0.0.0:8000
        ServerAlias gocloud
        DocumentRoot /usr/share/gocloud
        WSGIScriptAlias / "/usr/share/gocloud/gocloud.wsgi"
        WSGIPassAuthorization On
        Alias /static/ "/usr/share/gocloud/static/"
        <Directory "/usr/share/gocloud">
                Order deny,allow
                Allow from all
        </Directory>
        # SSLEngine on
        # SSLCertificateFile /etc/apache2/ssl/apache.crt
        # SSLCertificateKeyFile /etc/apache2/ssl/apache.key
</VirtualHost>
EOF
a2dissite 000-default
a2ensite gocloud
a2ensite gocloudapi

# enable https redirection
a2enmod rewrite
echo "RewriteEngine On" >> /etc/apache2/apache2.conf
echo "RewriteCond %{REQUEST_URI} ^/$" >> /etc/apache2/apache2.conf
echo "RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URL}" >> /etc/apache2/apache2.conf
echo "LimitRequestBody 10737418240" >> /etc/apache2/apache2.conf
echo "CustomLog \${APACHE_LOG_DIR}/access.log combined" >> /etc/apache2/apache2.conf

apt-get remove -y libapache2-mod-php5
a2dismod php5filter
a2dismod mpm_prefork
a2enmod mpm_event
