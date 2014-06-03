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
RUN mkvirtualenv devcon2014
# WORKDIR /opt/.virtualenvs/devcon2014
# setup current virtualenv
RUN workon devcon2014 && pip install Django
WORKDIR /opt/djangoprojects
# RUN git clone project location
# WORKDIR /opt/djangoprojects/devcon2014
# ENTRYPOINT [""]
# EXPOSE PORT
