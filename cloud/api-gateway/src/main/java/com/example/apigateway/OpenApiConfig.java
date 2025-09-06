package com.example.apigateway;

import org.springframework.cloud.gateway.route.RouteDefinitionLocator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import java.util.ArrayList;
import java.util.List;

@Configuration
public class OpenApiConfig {

    private final RouteDefinitionLocator locator;

    public OpenApiConfig(RouteDefinitionLocator locator) {
        this.locator = locator;
    }

    @Bean
    public List<GroupedOpenApi> apis() {
        List<GroupedOpenApi> groups = new ArrayList<>();
        List<String> routes = new ArrayList<>();
        locator.getRouteDefinitions().subscribe(routeDefinition -> routes.add(routeDefinition.getId()));
        routes.stream().filter(route -> route.matches(".*-service")).forEach(route -> {
            String name = route.replace("-service", "");
            groups.add(GroupedOpenApi.builder().pathsToMatch("/" + name + "/**").group(name).build());
        });
        return groups;
    }

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info().title("API Gateway").version("1.0").description("Documentation for API Gateway"));
    }
}