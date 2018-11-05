FROM centos:latest
RUN yum update -y && yum install -y bash openssh perl perl-devel gcc wget curl make openssl openssl-devel perl-ExtUtils-MakeMaker perl-Data-Dumper perl-Module-CoreList\
                && rm -rf /var/yum/cache/* /tmp/*
RUN curl -L https://cpanmin.us | perl - App::cpanminus
