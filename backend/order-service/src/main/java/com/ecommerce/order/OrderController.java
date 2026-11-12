package com.ecommerce.order;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getOrders() {
        Map<String, Object> order = new HashMap<>();
        order.put("orderId", "ORD-2026-9901");
        order.put("status", "CONFIRMED");
        order.put("total", 499.00);
        return ResponseEntity.ok(Collections.singletonList(order));
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody Map<String, Object> payload) {
        Map<String, Object> response = new HashMap<>(payload);
        response.put("orderId", "ORD-" + UUID.randomUUID().toString().substring(0, 8));
        response.put("status", "CREATED");
        return ResponseEntity.ok(response);
    }
}

