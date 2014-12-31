#!/bin/sh

JDK=jdk1.7.0_72
JDK_FILE=jdk-7u72-linux-x64.tar.gz

UPSOURCE_DIR=/opt/Upsource
UPSOURCE_VERSION=1.0.12551
UPSOURCE_NAME=upsource-$UPSOURCE_VERSION
UPSOURCE_ZIP=$UPSOURCE_NAME.zip
UPSOURCE_URL=http://download.jetbrains.com/upsource/$UPSOURCE_ZIP

# Install various packages required to run Upsource
if [ -f /etc/redhat-release ]; then
    yum -y install unzip
else
    apt-get update -y
    apt-get install -y -q unzip
fi

# Install Java
mkdir -p /opt
if [ ! -d /opt/$JDK ]; then
    tar -xzf /vagrant/files/$JDK_FILE -C /opt
fi

# Install Upsource zip file
if [ ! -d $UPSOURCE_DIR ]; then
    if [ ! -f /vagrant/files/$UPSOURCE_ZIP ]; then
        wget -q --no-proxy $UPSOURCE_URL -P /vagrant/files
    fi
    unzip -q /vagrant/files/$UPSOURCE_ZIP -d /opt
fi

if [ -f /etc/redhat-release ]; then
    # Allow connections
    iptables -I INPUT 5 -p tcp --dport 8080 -j ACCEPT
    iptables --line-numbers -L INPUT -n
    /sbin/service iptables save
fi

export JAVA_HOME=/opt/$JDK
export PATH=$PATH:$JAVA_HOME/bin

# Start Upsource
$UPSOURCE_DIR/bin/upsource.sh start
