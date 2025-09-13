package com.example.orderservice.client;

import com.example.orderservice.dto.User;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "user-service", path = "/users")
public interface UserClient {

    @GetMapping("/{id}")
    @CircuitBreaker(name = "userService", fallbackMethod = "fallbackForUserService")
    @Retry(name = "userService")
    User findById(@PathVariable("id") Long id);

    default User fallbackForUserService(Long id, Throwable throwable) {
        // Log the exception
        System.err.println("Fallback for UserService.findById(" + id + ") executed: " + throwable.getMessage());
        // Return a default or empty user
        return new User(id, "Fallback User", "fallback@example.com");
    }
}