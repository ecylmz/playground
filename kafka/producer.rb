#!/usr/bin/env ruby

# frozen_string_literal: true

require 'kafka'
require 'listen'

TOPIC_NAME = ENV['KAFKA_TOPIC_NAME'] || 'files'
TIMEOUT = ENV['KAFKA_CONNECT_TIMEOUT'] || 5

LISTEN_DIR = ENV['LISTEN_DIR'] || '/tmp/test'

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

def create_topic!(client, topic_name)
  client.create_topic(topic_name) unless client.topics.include?(topic_name)
rescue Kafka::TopicAlreadyExists
  warn "Topic already exists: #{topic_name}"
end

def main # rubocop:disable Metrics/MethodLength
  kafka = Kafka.new(
    seed_brokers: '10.0.3.15:9093',
    ssl_ca_cert: File.read('/vagrant/ssl/ca-cert'),
    ssl_client_cert: File.read('/vagrant/ssl/client.cer.pem'),
    ssl_client_cert_key: File.read('/vagrant/ssl/client.key.pem'),
    ssl_verify_hostname: false
  )
  connect_in_timeout kafka, TIMEOUT
  create_topic! kafka, TOPIC_NAME
  producer = kafka.async_producer

  listener = Listen.to(LISTEN_DIR) do |_, added, _|
    if added.any?
      added.each { |e| producer.produce(e, topic: TOPIC_NAME) }
      producer.deliver_messages
    end
  end
  listener.start
  sleep
end

main if $PROGRAM_NAME == __FILE__
