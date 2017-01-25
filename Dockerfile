FROM ubuntu:16.04
MAINTAINER Jonathan Dursi <jonathan@dursi.ca>
LABEL Description="Start up a GA4GH server against on a directory"

RUN apt-get update \
    && apt-get install -y \
        apache2 \
        libapache2-mod-wsgi \
        libcurl4-openssl-dev \
        libffi-dev \
        libssl-dev \
        libxslt1-dev \
        python-dev \
        python-pip \
        samtools \
        tabix \
        zlib1g-dev 

# enable WSGI
RUN a2enmod wsgi
    
# Python egg cache:
RUN mkdir /var/cache/apache2/python-egg-cache \
    && chown www-data:www-data /var/cache/apache2/python-egg-cache/

# install GA4GH server
RUN pip install ga4gh

# set up server directory
RUN mkdir -p /srv/ga4gh 

# copy config files
COPY config/application.wsgi /srv/ga4gh/application.wsgi
COPY config/config.py /srv/ga4gh/config.py
COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf

COPY scripts/* /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
