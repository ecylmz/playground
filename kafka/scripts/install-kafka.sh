#!/bin/bash

# default-jdk paketindeki bug'dan dolayı elle bu dizini oluşturmak zorundayız.
# ref: https://github.com/geerlingguy/ansible-role-java/issues/64#issuecomment-393299088
mkdir -p /usr/share/man/man1
apt -qq update && apt -qq install -y default-jdk

systemctl stop ufw && systemctl disable ufw

useradd kafka

mkdir /var/lib/kafka
mkdir /opt/kafka && pushd /opt/kafka || exit

curl -s https://downloads.apache.org/kafka/2.6.0/kafka_2.13-2.6.0.tgz -o /opt/kafka/kafka.tgz

tar -xvzf /opt/kafka/kafka.tgz --strip 1

sed -i 's/\/tmp\/kafka-logs/\/var\/lib\/kafka\/kafka-logs/g' config/server.properties
echo "delete.topic.enable = true" >> config/server.properties

sed -i 's/\/tmp\/zookeeper/\/var\/lib\/kafka\/zookeeper/g' config/zookeeper.properties

ln -sf /vagrant/systemd/kafka.service /etc/systemd/system/kafka.service
ln -sf /vagrant/systemd/zookeeper.service /etc/systemd/system/zookeeper.service

chown kafka:kafka -R /opt/kafka
chown kafka:kafka -R /var/lib/kafka

systemctl start kafka && systemctl enable kafka
