### Kafka Playground

### Terimler

Terimleri bilmek, yönetimdeki hakimiyeti artırır.

Producer:

Consumer:

Consumer Groups:

Broker:

Zookeeper:

### Test

`/tmp/test` dizini altına yeni bir dosya eklendiğinde `producer` kafka'ya iletiyor. `consumer` ise değişiklikleri
kafka'dan alıyor.

```bash
vagrant ssh client

# alttaki komutlar client sunucusunda verilir
nohup bash -c "/vagrant/producer.rb" > /dev/null 2&>1
/vagrant/consumer.rb

# Tmux kullanıyorsan "CTRL-B + c" ile kullanmıyorsan "CTRL-A + c" yeni bir terminal açıp aşağıdaki komutu ver
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
