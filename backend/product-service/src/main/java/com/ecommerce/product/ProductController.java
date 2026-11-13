package com.ecommerce.product;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final List<Map<String, Object>> catalog = new ArrayList<>();

    public ProductController() {
        catalog.add(createProduct("PROD-001", "Production Kubernetes Guide", "Comprehensive guide to multi-cloud enterprise EKS/GKE.", 59.99, "Books", 150));
        catalog.add(createProduct("PROD-002", "Terraform Cloud Automation Suite", "Pre-built modular infrastructure patterns for AWS & Azure.", 129.50, "Software", 80));
        catalog.add(createProduct("PROD-003", "Full Stack Observability Stack", "Prometheus, Grafana & Loki telemetry accelerator kit.", 89.00, "DevOps", 200));
        catalog.add(createProduct("PROD-004", "Enterprise Security Scanner CLI", "Integrated Trivy, Snyk, and OWASP compliance scanner.", 199.00, "Security", 60));
    }

    private Map<String, Object> createProduct(String id, String name, String desc, double price, String category, int stock) {
        Map<String, Object> item = new HashMap<>();
        item.put("id", id);
        item.put("name", name);
        item.put("description", desc);
        item.put("price", price);
        item.put("category", category);
        item.put("inStock", stock > 0);
        item.put("stockQuantity", stock);
        return item;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getProducts() {
        return ResponseEntity.ok(catalog);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getProductById(@PathVariable String id) {
        return catalog.stream()
                .filter(p -> id.equalsIgnoreCase((String) p.get("id")))
                .findFirst()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}

