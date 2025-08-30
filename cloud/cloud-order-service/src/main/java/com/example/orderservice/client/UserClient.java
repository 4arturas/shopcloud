package com.example.orderservice.client;

import com.example.orderservice.dto.User;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class UserClient {

    private final RestTemplate restTemplate;

    public UserClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public User findById(Long id) {
        return restTemplate.getForObject("http://user-service:8081/users/{id}", User.class, id);
    }
}