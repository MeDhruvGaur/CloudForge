package com.ecommerce.user;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getCurrentUser() {
        Map<String, Object> user = new HashMap<>();
        user.put("id", 1L);
        user.put("username", "devops_admin");
        user.put("email", "admin@ecommerce.com");
        user.put("role", "ROLE_ADMIN");
        return ResponseEntity.ok(user);
    }
}

