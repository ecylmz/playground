### Kafka Playground

### Terimler

Terimleri bilmek, yönetimdeki hakimiyeti artırır.

Broker: Kafka sunucunun kendisine verilen bir sıfat. Broker'ı Türkçe'ye simsar olarak çevirmek daha doğru gibi.
`Producer`'dan alır, `Consumer`'a verir.

Producer:

Consumer:

Consumer Groups:

Zookeeper:

### Kafka Kurulumu

Kurulumun nasıl yapıldığını görmek için: [install-kafka.sh](scripts/install-kafka.sh)

SSL yapılandırmasını görmek için: [enable-ssl.sh](scripts/enable-ssl.sh)

### Test

`/tmp/test` dizini altına yeni bir dosya eklendiğinde `producer` kafka'ya iletiyor. `consumer` ise değişiklikleri
kafka'dan alıyor.

```bash
vagrant ssh

# Tmux kullanıyorsan "CTRL-B + c" ile kullanmıyorsan "CTRL-A + c" ile her komut için yeni bir terminal aç.
/vagrant/examples/producer-ssl.rb
/vagrant/examples/consumer-ssl.rb

touch /tmp/test/foo.rb
```

`CTRL-B + TAB` tuşlarına bastığında `consumer.rb`'nin çalıştığı terminale geçiş yaparsın.
`foo.rb`'nin buraya düştüğünü görebilirsin.

### Kaynaklar

- https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-debian-10
- https://tecadmin.net/install-apache-kafka-debian/
- https://docs.confluent.io/current/security/security_tutorial.html#generating-keys-certs
- https://topic.alibabacloud.com/a/golang-client-sarama-via-ssl-connection-kafka-configuration_1_38_30917937.html
- https://github.com/heroku/heroku-kafka-demo-ruby
