package com.example.orderservice.client;

import com.example.orderservice.dto.Product;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "product-service", path = "/products")
public interface ProductClient {

    @GetMapping("/{id}")
    @CircuitBreaker(name = "productService", fallbackMethod = "fallbackForProductService")
    @Retry(name = "productService")
    Product findById(@PathVariable("id") Long id);

    default Product fallbackForProductService(Long id, Throwable throwable) {
        // Log the exception
        System.err.println("Fallback for ProductService.findById(" + id + ") executed: " + throwable.getMessage());
        // Return a default or empty product
        return new Product(id, "Fallback Product", "Fallback Description", 0.0);
    }
}