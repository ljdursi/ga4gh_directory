FROM ubuntu:16.10
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
        unzip \
        wget \
        zlib1g-dev 

# enable WSGI
RUN a2enmod wsgi
    
# Python egg cache:
RUN mkdir /var/cache/apache2/python-egg-cache \
    && chown www-data:www-data /var/cache/apache2/python-egg-cache/

RUN pip install ga4gh 

RUN pip uninstall -y protobuf

# get and install protobuf manually - first C++
RUN cd /tmp \
    && wget -nv --no-check-certificate https://github.com/google/protobuf/releases/download/v3.2.0/protobuf-python-3.2.0.zip \
    && unzip protobuf-python-3.2.0.zip \
    && rm -f protobuf-python-3.2.0.zip \
    && cd protobuf-3.2.0 \
    && ./configure \
    && make \
    && make check \
    && make install \
    && ldconfig 

# and now python
RUN cd /tmp/protobuf-3.2.0 \
    && cd python \
    && python setup.py build --cpp_implementation \
    && python setup.py test --cpp_implementation \
    && python setup.py install --cpp_implementation \
    && cd /tmp \
    && rm -rf protobuf-3.2.0

# set up server directory
RUN mkdir -p /srv/ga4gh 

# copy config files
COPY config/application.wsgi /srv/ga4gh/application.wsgi
COPY config/config.py /srv/ga4gh/config.py
COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf

COPY scripts/* /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
