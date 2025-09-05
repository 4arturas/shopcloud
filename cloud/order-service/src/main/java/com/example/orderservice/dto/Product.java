package com.example.orderservice.dto;

import java.math.BigDecimal;

public record Product(Long id, String name, String description, BigDecimal price) {
}