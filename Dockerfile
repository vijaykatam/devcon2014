# This is a Dockerfile to create an image for a Django application with Python 2.7 on centos
#
# VERSION      0.1
FROM centos
MAINTAINER Vijay Katam vijay.katam@cerner.com

# Prereqs
RUN yum -y install wget gcc.x86_64 make zlib-devel sqlite-devel openssl-devel bzip2-devel tix-devel tk-devel ncurses-devel readline-devel gdbm-devel glibc-devel
RUN yum -y install gmp-devel gcc-c++ libxml2-devel libxslt-devel git subversion dtach httpd httpd-devel sqllite-tcl autoconf libffi-devel libGL-devel
RUN yum -y install bind-utils sudo which

# Python 2.7 rpm
# http://developerblog.redhat.com/2013/02/14/setting-up-django-and-python-2-7-on-red-hat-enterprise-6-the-easy-way/
RUN wget -qO- http://people.redhat.com/bkabrda/scl_python27.repo >> /etc/yum.repos.d/scl.repo

# Python 2.7 install
RUN yum -y install python27
ENV PATH /opt/rh/python27/root/usr/bin:$PATH
#RUN scl enable python27 bash
ENV LD_LIBRARY_PATH /opt/rh/python27/root/usr/lib64

# pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python2.7 get-pip.py

# virtualenvwrapper
RUN pip install virtualenvwrapper

# configure virtualenv vars
RUN mkdir -p /opt/.virtualenvs
RUN mkdir /opt/.virtualenvs/dists
ENV WORKON_HOME /opt/.virtualenvs

# django projects location
ENV PROJECT_HOME /opt/djangoprojects
# add wrapper to bashrc
RUN bash -c 'echo ". /opt/rh/python27/root/usr/bin/virtualenvwrapper.sh" > /.bashrc'

# setup virtualenv for app and its location
RUN mkdir -p /opt/djangoprojects/devcon2014
RUN source /opt/rh/python27/root/usr/bin/virtualenvwrapper.sh && mkvirtualenv devcon2014

# setup current virtualenv
RUN source /opt/rh/python27/root/usr/bin/virtualenvwrapper.sh && workon devcon2014 && pip install Django
RUN source /opt/rh/python27/root/usr/bin/virtualenvwrapper.sh && workon devcon2014 && pip install supervisor
RUN source /opt/rh/python27/root/usr/bin/virtualenvwrapper.sh && workon devcon2014 && pip install gunicorn

# sshd
RUN echo 'root:secret' | chpasswd
RUN yum install -y openssh-server
RUN mkdir -p /var/run/sshd ; chmod -rx /var/run/sshd
# http://stackoverflow.com/questions/2419412/ssh-connection-stop-at-debug1-ssh2-msg-kexinit-sent
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
# Bad security, add a user and sudo instead!
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
# http://stackoverflow.com/questions/18173889/cannot-access-centos-sshd-on-docker
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

WORKDIR /opt/djangoprojects
RUN rm -rf devcon2014
RUN git clone https://github.com/vijaykatam/devcon2014.git
WORKDIR /opt/djangoprojects/devcon2014/sample_app
EXPOSE 8000 22
CMD ["-c", "/opt/djangoprojects/devcon2014/supervisord.conf"]
ENTRYPOINT ["/opt/.virtualenvs/devcon2014/bin/supervisord"]


