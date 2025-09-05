package com.example.orderservice.service;

import com.example.orderservice.client.ProductClient;
import com.example.orderservice.client.UserClient;
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
    private KafkaTemplate<String, String> kafkaTemplate;

    public Order createOrder(Order order) {
        // For simplicity, we are not doing any validation
        // In a real application, you would validate the user and product
        Product product = productClient.findById(order.getProductId());
        User user = userClient.findById(order.getUserId());

        if (product == null || user == null) {
            throw new RuntimeException("User or Product not found");
        }

        Order savedOrder = orderRepository.save(order);

        try {
            ObjectMapper objectMapper = new ObjectMapper();
            String message = objectMapper.writeValueAsString(savedOrder);
            kafkaTemplate.send("order-placed", message);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }

        return savedOrder;
    }
}
