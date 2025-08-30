package com.example.notificationservice.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumerService {

    private static final Logger LOGGER = LoggerFactory.getLogger(KafkaConsumerService.class);

    @KafkaListener(topics = "user-registered", groupId = "notification-group")
    public void consumeUserRegistered(String message) {
        LOGGER.info(String.format("User registered message received -> %s", message));
        // Here you would add the logic to send a welcome email
    }

    @KafkaListener(topics = "order-placed", groupId = "notification-group")
    public void consumeOrderPlaced(String message) {
        LOGGER.info(String.format("Order placed message received -> %s", message));
        // Here you would add the logic to send an order confirmation email
    }
}
