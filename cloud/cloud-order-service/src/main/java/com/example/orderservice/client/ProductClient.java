package com.example.orderservice.client;

import com.example.orderservice.dto.Product;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "product-service", url = "http://product-service:8082")
public interface ProductClient {

    @GetMapping("/products/{id}")
    Product findById(@PathVariable("id") Long id);
}
