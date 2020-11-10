#!/usr/bin/env ruby

# frozen_string_literal: true

require 'kafka'

GROUP_ID = ENV['KAFKA_GROUP_ID'] || 'ruby-consumer'
TOPIC_NAME = ENV['KAFKA_TOPIC_NAME'] || 'files'
TIMEOUT = ENV['KAFKA_CONNECT_TIMEOUT'] || 5

def connect_in_timeout(client, timeout)
  1.upto(timeout) do |retry_count|
    begin
      client.topics
      return nil
    rescue Kafka::ConnectionError
      warn "Connection failed. ( #{retry_count} )"
      sleep 1
    end
  end
  exit(1)
end

def main # rubocop:disable Metrics/MethodLength
  kafka = Kafka.new(
    seed_brokers: '10.0.3.15:9093',
    ssl_ca_cert: File.read('/vagrant/ssl/ca-cert'),
    ssl_client_cert: File.read('/vagrant/ssl/client.cer.pem'),
    ssl_client_cert_key: File.read('/vagrant/ssl/client.key.pem'),
    ssl_verify_hostname: false
  )

  connect_in_timeout(kafka, TIMEOUT)

  p kafka.topics
  consumer = kafka.consumer(group_id: GROUP_ID)
  consumer.subscribe(TOPIC_NAME)
  trap('TERM') { consumer.stop }

  consumer.each_message do |message|
    warn "#{message.offset}, Key: #{message.key}, Value: #{message.value}"
  end
end

main if $PROGRAM_NAME == __FILE__
