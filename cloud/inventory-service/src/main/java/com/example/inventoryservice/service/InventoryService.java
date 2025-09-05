package com.example.inventoryservice.service;

import com.example.inventoryservice.entity.Inventory;
import com.example.inventoryservice.repository.InventoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class InventoryService {

    @Autowired
    private InventoryRepository inventoryRepository;

    public Inventory getInventoryByProductId(Long productId) {
        return inventoryRepository.findByProductId(productId);
    }

    public Inventory updateInventory(Long productId, Integer quantity) {
        Inventory inventory = inventoryRepository.findByProductId(productId);
        if (inventory != null) {
            inventory.setQuantity(inventory.getQuantity() - quantity);
            return inventoryRepository.save(inventory);
        }
        return null;
    }
}
