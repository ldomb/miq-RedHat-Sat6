# miq-RedHat-Sat6

## General Information

| Name      | miq-RedHat-Satellite6 |
| --- | --- | --- |
| License   | GPL v2 (see LICENSE file) |
| Version   | 1.1 |

## Author
| Name      | E-mail |
| --- | --- |
| Laurent Domb | laurent@redhat.com |

## Packager
| Name              | E-mail |
| --- | --- |
| Laurent Domb    | laurent@redhat.com |


## Install
1) Download import/export rake scripts
<br>
cd /tmp
<br>
if [ -d cfme-rhconsulting-scripts-master ] ; then
    rm -fR /tmp/cfme-rhconsulting-scripts-master
fi
<br>
wget -O cfme-rhconsulting-scripts.zip https://github.com/rhtconsulting/cfme-rhconsulting-scripts/archive/master.zip
<br>
unzip cfme-rhconsulting-scripts.zip
<br>
cd cfme-rhconsulting-scripts-master
<br>
make install
<br>

2) Install {project-name} on appliance
<br>
PROJECT_NAME="miq-RedHat-Sat6"
<br>
PROJECT_ZIP="wget --no-check-certificate https://github.com/ldomb/miq-RedHat-Sat6/archive/master.zip"
<br>
cd /tmp
<br>
wget -O ${PROJECT_NAME}.zip ${PROJECT_ZIP}
<br>
unzip ${PROJECT_NAME}.zip
<br>
cd ${PROJECT_NAME}-master
<br>
sh install.sh
