package com.example.orderservice.client;

import com.example.orderservice.dto.Product;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class ProductClient {

    private final RestTemplate restTemplate;

    public ProductClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public Product findById(Long id) {
        return restTemplate.getForObject("http://product-service:8080/products/{id}", Product.class, id);
    }
}