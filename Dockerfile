FROM ubuntu:xenial
MAINTAINER Chris Hardekopf <chrish@basis.com>

# Install websvn
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y viewvc \
    subversion apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# Set configuration
RUN perl -pi -e \
    's/^#root_parents\s*=.*$/root_parents = \/svn: svn/g' \
    /etc/viewvc/viewvc.conf

RUN perl -pi -e \
    's/^#default_root\s*=.*$/default_root = svn/g' \
    /etc/viewvc/viewvc.conf

RUN perl -pi -e \
    's/^#authorizer\s*=.*$/authorizer = svnauthz/g' \
    /etc/viewvc/viewvc.conf

RUN perl -pi -e \
    's/^#authzfile\s*=.*$/authzfile = \/svn\/svn.authz/g' \
    /etc/viewvc/viewvc.conf

RUN perl -pi -e \
    's/^#docroot\s*=.*$/docroot = \/docroot/g' \
    /etc/viewvc/viewvc.conf

RUN perl -pi -e \
    's/^#log_pagesize\s*=.*$/log_pagesize = 20/g' \
    /etc/viewvc/viewvc.conf

RUN perl -pi -e \
    's/^#max_filesize_kbytes\s*=.*$/max_filesize_kbytes = 1024/g' \
    /etc/viewvc/viewvc.conf

# Add the viewvc apache configuration and enable the site
ADD viewvc.conf /etc/apache2/sites-available/
RUN a2enmod cgid expires auth_digest authz_groupfile && \
    a2dissite 000-default && a2ensite viewvc

# Add the start script
ADD start /opt/

# Archives and configuration are stored in /svn
VOLUME [ "/svn" ]

# Expose public port for web server
EXPOSE 80

# Initialize configuration and run the web server
CMD [ "/opt/start" ]


