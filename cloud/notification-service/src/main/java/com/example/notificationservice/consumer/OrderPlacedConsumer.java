package com.example.notificationservice.consumer;

import com.example.notificationservice.dto.OrderPlacedEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class OrderPlacedConsumer {

    private final ObjectMapper objectMapper;

    public OrderPlacedConsumer(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @KafkaListener(topics = "order-placed", groupId = "notification-group")
    public void listenOrderPlacedEvent(String message) {
        try {
            OrderPlacedEvent event = objectMapper.readValue(message, OrderPlacedEvent.class);
            System.out.println("Received OrderPlacedEvent: " + event);
            // Here you would implement the logic to send an order confirmation (e.g., email, push notification)
            System.out.println("Sending order confirmation for Order ID: " + event.getOrderId());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
