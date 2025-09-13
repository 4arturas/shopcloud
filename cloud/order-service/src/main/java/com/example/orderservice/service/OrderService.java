package com.example.orderservice.service;

import com.example.orderservice.dto.Inventory;
import com.example.orderservice.client.InventoryClient;
import com.example.orderservice.client.ProductClient;
import com.example.orderservice.client.UserClient;
import com.example.orderservice.dto.OrderPlacedEvent;
import com.example.orderservice.dto.Product;
import com.example.orderservice.dto.User;
import com.example.orderservice.entity.Order;
import com.example.orderservice.repository.OrderRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ProductClient productClient;

    @Autowired
    private UserClient userClient;

    @Autowired
    private InventoryClient inventoryClient;

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    public Order createOrder(Order order) {
        // In a real application, you would validate the user and product
        Product product = productClient.findById(order.getProductId());
        User user = userClient.findById(order.getUserId());
        Inventory inventory = inventoryClient.getInventoryByProductId(order.getProductId());

        if (product == null || user == null) {
            throw new RuntimeException("User or Product not found");
        }

        if (inventory == null || inventory.getStock() < order.getQuantity()) {
            throw new RuntimeException("Insufficient stock for product: " + order.getProductId());
        }

        Order savedOrder = orderRepository.save(order);

        try {
            ObjectMapper objectMapper = new ObjectMapper();
            OrderPlacedEvent event = new OrderPlacedEvent(savedOrder.getId(), savedOrder.getUserId(), savedOrder.getProductId(), savedOrder.getQuantity());
            String message = objectMapper.writeValueAsString(event);
            kafkaTemplate.send("order-placed", message);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }

        return savedOrder;
    }
}