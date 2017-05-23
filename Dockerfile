FROM ubuntu:17.04
MAINTAINER Jonathan Dursi <jonathan@dursi.ca>
LABEL Description="Start up a GA4GH server against on a directory"

RUN apt-get update \
    && apt-get install -y \
        apache2 \
        git \
        libapache2-mod-wsgi \
        libcurl4-openssl-dev \
        libffi-dev \
        libssl-dev \
        libxslt1-dev \
        python-dev \
        python-pip \
        samtools \
        tabix \
        unzip \
        wget \
        zlib1g-dev 

# enable WSGI
RUN a2enmod wsgi
    
# Python egg cache:
RUN mkdir /var/cache/apache2/python-egg-cache \
    && chown www-data:www-data /var/cache/apache2/python-egg-cache/

RUN git clone https://github.com/ljdursi/ga4gh-server.git \
    && cd ga4gh-server/ \
    && git fetch \
    && git checkout genotypes \
    && pip install -r dev-requirements.txt -c constraints.txt \
    && pip install . 

# set up server directory
RUN mkdir -p /srv/ga4gh 

# work around broken ga4gh config in master
RUN mkdir -p /srv/ga4gh/ga4gh/server/templates/ \
    && touch /srv/ga4gh/ga4gh/server/templates/initial_peers.txt

# copy config files
COPY config/application.wsgi /srv/ga4gh/application.wsgi
COPY config/config.py /srv/ga4gh/config.py
COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf

COPY scripts/* /usr/local/bin/

## fix security issues w/ bash 4.4-ubuntu1
RUN apt-get install --only-upgrade bash

ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
