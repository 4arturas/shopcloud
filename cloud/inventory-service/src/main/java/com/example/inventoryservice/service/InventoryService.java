package com.example.inventoryservice.service;

import com.example.inventoryservice.entity.Inventory;
import com.example.inventoryservice.repository.InventoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class InventoryService {

    private final InventoryRepository inventoryRepository;

    @Transactional(readOnly = true)
    public boolean isInStock(String skuCode) {
        Optional<Inventory> inventoryOptional = inventoryRepository.findBySkuCode(skuCode);
        return inventoryOptional.isPresent() && inventoryOptional.get().getQuantity() > 0;
    }
}
