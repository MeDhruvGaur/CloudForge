package com.ecommerce.payment;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    @PostMapping("/process")
    public ResponseEntity<Map<String, Object>> processPayment(@RequestBody Map<String, Object> paymentPayload) {
        Map<String, Object> response = new HashMap<>();
        String transactionId = "TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        response.put("transactionId", transactionId);
        response.put("status", "SUCCESS");
        response.put("amount", paymentPayload.getOrDefault("amount", 0.0));
        response.put("timestamp", new Date().toString());
        response.put("gateway", "STRIPE-MOCK-PROD");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/verify/{transactionId}")
    public ResponseEntity<Map<String, Object>> verifyPayment(@PathVariable String transactionId) {
        Map<String, Object> response = new HashMap<>();
        response.put("transactionId", transactionId);
        response.put("status", "VERIFIED");
        response.put("currency", "USD");
        return ResponseEntity.ok(response);
    }
}

