ARG ZONEMINDER_VERSION

FROM library/alpine
ARG ZONEMINDER_VERSION
ENV ZONEMINDER_VERSION ${ZONEMINDER_VERSION}

RUN \
    wget https://raw.githubusercontent.com/ZoneMinder/zmdockerfiles/master/utils/entrypoint.sh \
        -O /usr/local/bin/entrypoint.sh && \
    apk update && apk upgrade && \
    apk add \
        apache2 \
        apache2-proxy \
        apache2-ssl \
        file \
        libva-intel-driver \
        mariadb \
        mariadb-client \
        mesa \
        php-apache2 \
        php-fpm \
        php-intl \
        shadow \
        zip \
        zoneminder=${ZONEMINDER_VERSION} && \
    sed -i 's/^\(#?LoadModule mpm_event_module .*\)/\1/' /etc/apache2/httpd.conf && \
    sed -i 's/^\(#?LoadModule mpm_prefork_module .*\)/#\1/' /etc/apache2/httpd.conf && \
    sed -i 's/^\(user = \).*/\1apache/' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's/^\(group = \).*/\1apache/' /etc/php81/php-fpm.d/www.conf && \
    echo $'<FilesMatch \.php$>\n\
    SetHandler "proxy:fcgi://127.0.0.1:9000"\n\
</FilesMatch>\n\
DirectoryIndex index.php index.html' >/etc/apache2/conf.d/php81-module.conf && \
    ln -sf /etc/zm/www/zoneminder.conf /etc/apache2/conf.d && \
    echo "ServerName localhost" >/etc/apache2/conf.d/servername.conf && \
    echo -e "# Redirect the webroot to /zm\nRedirectMatch permanent ^/$ /zm" \
        >/etc/apache2/conf.d/redirect.conf && \
    mv -f /etc/php81/php.ini /etc/php.ini && \
    ln -s /etc/php.ini /etc/php81/php.ini && \
    mv -f /usr/bin/mariadb-install-db /usr/bin/mysql_install_db && \
    ln -s /usr/bin/mysql_install_db /usr/bin/mariadb-install-db && \
    mv -f /usr/sbin/php-fpm81 /usr/sbin/php-fpm && \
    ln -s /usr/sbin/php-fpm /usr/sbin/php-fpm81 && \
    install -m 750 -o apache -g apache -d /var/cache/zoneminder && \
    install -m 770 -o root -g apache -d /var/lib/zoneminder && \
    install -m 770 -o root -g apache -d /var/log/zoneminder && \
    ln -s /var/log/zoneminder /var/log/zm && \
    chown -R root:apache /etc/zm && \
    chmod 755 /usr/local/bin/entrypoint.sh && \
    apk del apk-tools && \
    rm -rf /etc/apk /lib/apk /usr/lib/apk /usr/share/apk /var/lib/apk && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* /var/tmp/* /run/* /dev/shm/* && \
    install -m 750 -o apache -g apache -d /run/apache2

VOLUME /var/lib/zoneminder/events /var/lib/mysql /var/log/zoneminder

EXPOSE 443

CMD ["/bin/sh"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
