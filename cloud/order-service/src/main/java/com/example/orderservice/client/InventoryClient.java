package com.example.orderservice.client;

import com.example.orderservice.dto.Inventory;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "inventory-service", path = "/inventory")
public interface InventoryClient {

    @GetMapping("/{productId}")
    @CircuitBreaker(name = "inventoryService", fallbackMethod = "fallbackForInventoryService")
    @Retry(name = "inventoryService")
    Inventory getInventoryByProductId(@PathVariable("productId") Long productId);

    default Inventory fallbackForInventoryService(Long productId, Throwable throwable) {
        // Log the exception
        System.err.println("Fallback for InventoryService.getInventoryByProductId(" + productId + ") executed: " + throwable.getMessage());
        // Return a default or empty inventory
        Inventory inventory = new Inventory();
        inventory.setProductId(productId);
        inventory.setStock(0);
        return inventory;
    }
}
