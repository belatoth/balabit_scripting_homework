#!/bin/bash

export LANG=C

set -e
set -o pipefail

rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
rpm --import https://getfedora.org/static/352C64E5.txt

# ensure our os-version is up-to-date
yum update -y
# Add extra repository
yum install -y epel-release

# install perl (and the module manager)
yum install -y perl perl-CPAN perl-CPANPLUS
yum install -y perl-Test-Output

# install the necessary build tools and libraries for the perl modules
yum install -y make gcc gcc-c++ kernel-devel patch
yum install -y vim
yum install -y openssl
yum install -y expat-devel
yum install -y libxml2 libxml2-devel
yum install -y cronie

####
# PERL module installation
####
mkdir -p /root/.cpan/CPAN
# if you have problems with one of the cpan servers being down
# here a modified MyConfig.pm file that solves this issue, but
# ideally this is not required
# cp /docker/tkrobotng_base/MyConfig.pm /root/.cpan/CPAN/

# A hack to get cpan working without questions: http://www.perlmonks.org/?node_id=548581
# get the location of CPAN::FirstTime.pm
#export PREFIX=`perl -V:privlib`
#${PREFIX##"privlib="}

# force CPAN::FirstTime to not default to manual
# setup, since initial CPAN setup needs to be automated
#perl -pi -e'$. == 73 and s/yes/no/' $PREFIX/CPAN/FirstTime.pm

# make CPAN set itself up with defaults and no intervention
#perl -MCPAN -MCPAN::Config -MCPAN::FirstTime -e'CPAN::FirstTime::init'

# undo the change
#perl -pi -e'$. == 73 and s/no/yes/' $PREFIX/CPAN/FirstTime.pm

export FTP_PASSIVE=1
export PERL_MM_USE_DEFAULT=1
export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"
mkdir -p /root/.cpanplus/custom-sources
# install all the necessary perl modules

echo "installing Test::Warn"
cpanp -i --force Test::Warn
echo "installing CGI"
cpanp -i CGI
echo "installing Data::Dumper"
cpanp -i Data::Dumper
echo "installing JSON"
cpanp -i JSON
echo "installing LWP::UserAgent"
cpanp -i LWP::UserAgent
echo "installing HTML::TreeBuilder"
cpanp -i HTML::TreeBuilder
echo "installing HTML::TreeBuilder::XPath"
cpanp -i HTML::TreeBuilder::XPath
echo "installing WWW::Mechanize"
cpanp -i --force WWW::Mechanize
echo "installing Log::Log4perl"
cpanp -i Log::Log4perl
echo "installing Encode"
cpanp -i Encode

####
# Cleanup
####
# remove all the temporary files from cpan
/usr/bin/rm -rf /root/.cpanplus/
# Remove the dev tools here again? (filling up /usr/...)
# This will also limit harm, because nothing can be compiled
yum remove -y make gcc gcc-c++ kernel-devel patch
# remove the yum cache files
yum clean all
