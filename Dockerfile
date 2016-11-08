FROM php:7.0-apache
MAINTAINER Marc Billow <mbillow@csh.rit.edu>

# Install PHP extensions and configure Apache
RUN a2enmod rewrite && \
    set -xe && \
    apt-get update && \
    apt-get install -y libpng12-dev libjpeg-dev libmcrypt-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-install gd mcrypt mbstring mysqli zip

# Download the latest release of OpenCart
RUN	rm -rf /var/www/html && \
    cd /tmp && \
	curl -L -o opencart-latest.tar.gz $(\
	curl -s https://api.github.com/repos/opencart/opencart/releases | \
	grep tarball_url | head -n 1 | cut -d '"' -f 4) && \
	tar -zxvf opencart-latest.tar.gz && \
	rm -f opencart-latest.tar.gz && \
	mv $(ls -d * | grep opencart)/upload /var/www/html && \
	rm -rf $(ls -d * | grep opencart-) && \
	cd /var/www/html && \
	mv config-dist.php config.php && \
	mv admin/config-dist.php admin/config.php && \
    chmod og+rwx config.php admin/config.php && \
	chown -R www-data /var/www/html && \
    sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf

# Drop privileges
USER www-data

# Expose the default port
EXPOSE 8080
