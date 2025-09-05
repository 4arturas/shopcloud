package com.example.inventoryservice.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumerService {

    @Autowired
    private InventoryService inventoryService;

    @KafkaListener(topics = "order-placed", groupId = "inventory-group")
    public void consume(String message) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonNode = objectMapper.readTree(message);
            long productId = jsonNode.get("productId").asLong();
            int quantity = jsonNode.get("quantity").asInt();
            inventoryService.updateInventory(productId, quantity);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
    }
}
