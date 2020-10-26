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

ln -sf /vagrant/kafka.service /etc/systemd/system/kafka.service
ln -sf /vagrant/zookeeper.service /etc/systemd/system/zookeeper.service

chown kafka:kafka -R /opt/kafka
chown kafka:kafka -R /var/lib/kafka

systemctl start kafka && systemctl enable kafka

rm -rf /vagrant/ssl
mkdir /vagrant/ssl && pushd /vagrant/ssl || exit

# generate certificate
keytool -noprompt -keystore kafka.server.keystore.jks -alias localhost -keyalg RSA -validity 3650 -genkey -storepass test123 -keypass test123 -dname "CN=kafka, OU=BAUM, O=OMU, L=Samsun, ST=Samsun, C=TR"

openssl req -new -x509 -keyout ca-key -out ca-cert -days 3650 -subj "/C=TR/ST=Samsun/L=Samsun/O=OMU/CN=kafka" -passout pass:test123 &>/dev/null
keytool -keystore kafka.client.truststore.jks -alias CARoot -import -file ca-cert -storepass test123 -noprompt
keytool -keystore kafka.server.truststore.jks -alias CARoot -import -file ca-cert -storepass test123 -noprompt

keytool -keystore kafka.server.keystore.jks -alias localhost -certreq -file cert-file -storepass test123
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 3650 -CAcreateserial -passin pass:test123
keytool -keystore kafka.server.keystore.jks -alias CARoot -import -file ca-cert -storepass test123 -noprompt
keytool -keystore kafka.server.keystore.jks -alias localhost -import -file cert-signed -storepass test123 -noprompt

keytool -importkeystore -srckeystore kafka.server.truststore.jks -destkeystore server.p12 -deststoretype PKCS12 -srcstorepass test123 -deststorepass test123
openssl pkcs12 -in server.p12 -nokeys -out server.cer.pem -passin pass:test123
keytool -importkeystore -srckeystore kafka.server.keystore.jks -destkeystore client.p12 -deststoretype PKCS12 -srcstorepass test123 -deststorepass test123
openssl pkcs12 -in client.p12 -nokeys -out client.cer.pem -passin pass:test123
openssl pkcs12 -in client.p12 -nodes -nocerts -out client.key.pem -passin pass:test123

cat <<EOT >> /opt/kafka/config/server.properties

security.inter.broker.protocol=SSL
listeners=SSL://10.0.3.15:9093
advertised.listeners=SSL://10.0.3.15:9093

ssl.client.auth=required
ssl.endpoint.identification.algorithm=
ssl.truststore.location=/vagrant/ssl/kafka.server.truststore.jks
ssl.truststore.password=test123
ssl.keystore.location=/vagrant/ssl/kafka.server.keystore.jks
ssl.keystore.password=test123
ssl.key.password=test123
EOT

chown op:op -R /vagrant/ssl

systemctl restart kafka
