#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

GP="com/smeinvoice"

# ---------- common-lib ----------
mkdir -p common-lib/src/main/java/$GP/common
cat > common-lib/pom.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>com.smeinvoice</groupId>
        <artifactId>sme-invoice-marketplace</artifactId>
        <version>0.1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <artifactId>common-lib</artifactId>
    <packaging>jar</packaging>
    <name>common-lib</name>
</project>
EOF
cat > common-lib/src/main/java/$GP/common/Role.java <<'EOF'
package com.smeinvoice.common;

public enum Role {
    SME, INVESTOR, ADMIN
}
EOF
cat > common-lib/src/main/java/$GP/common/SecurityHeaders.java <<'EOF'
package com.smeinvoice.common;

/** Headers set by the API Gateway after it validates the JWT. */
public final class SecurityHeaders {
    public static final String USER_ID = "X-User-Id";
    public static final String USER_ROLE = "X-User-Role";

    private SecurityHeaders() { }
}
EOF

# ---------- shared Dockerfile ----------
write_dockerfile() {
  local name="$1" port="$2"
  cat > "$name/Dockerfile" <<EOF
# Build from repo root:  docker build -f $name/Dockerfile -t sme/$name .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn -B -q -pl $name -am -DskipTests package

FROM eclipse-temurin:17-jre
RUN useradd -r -u 1001 appuser
WORKDIR /app
COPY --from=build /workspace/$name/target/*.jar app.jar
USER appuser
EXPOSE $port
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh","-c","java \$JAVA_OPTS -jar app.jar"]
EOF
}

render() {
  sed -e "s/__NAME__/$name/g" -e "s/__PORT__/$port/g" -e "s/__DB__/$db/g" \
      -e "s/__PKG__/$pkg/g" -e "s/__CLS__/$cls/g"
}

# ---------- standard backend service ----------
gen_service() {
  local name="$1" port="$2" db="$3" pkg="$4" cls="$5"
  local base="$name/src/main/java/$GP/$pkg"
  mkdir -p "$base/config" "$name/src/main/resources/db/migration" "$name/src/test/java/$GP/$pkg"
  touch "$name/src/main/resources/db/migration/.gitkeep"

  cat <<'EOF' | render > "$name/pom.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>com.smeinvoice</groupId>
        <artifactId>sme-invoice-marketplace</artifactId>
        <version>0.1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <artifactId>__NAME__</artifactId>
    <name>__NAME__</name>

    <dependencies>
        <dependency><groupId>com.smeinvoice</groupId><artifactId>common-lib</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-security</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>
        <dependency><groupId>org.springframework.kafka</groupId><artifactId>spring-kafka</artifactId></dependency>
        <dependency><groupId>org.flywaydb</groupId><artifactId>flyway-core</artifactId></dependency>
        <dependency><groupId>org.flywaydb</groupId><artifactId>flyway-database-postgresql</artifactId></dependency>
        <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>

        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-test</artifactId><scope>test</scope></dependency>
        <dependency><groupId>org.springframework.security</groupId><artifactId>spring-security-test</artifactId><scope>test</scope></dependency>
        <dependency><groupId>org.springframework.kafka</groupId><artifactId>spring-kafka-test</artifactId><scope>test</scope></dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

  cat <<'EOF' | render > "$base/__CLS__.java"
package com.smeinvoice.__PKG__;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class __CLS__ {
    public static void main(String[] args) {
        SpringApplication.run(__CLS__.class, args);
    }
}
EOF
  mv "$base/__CLS__.java" "$base/$cls.java" 2>/dev/null || true

  cat <<'EOF' | render > "$base/config/SecurityConfig.java"
package com.smeinvoice.__PKG__.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Phase 1 placeholder: only the health endpoint is open.
 * Real header-based role checks (X-User-Id / X-User-Role from the gateway) arrive in Phase 3.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // stateless API behind the gateway
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(a -> a
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                .anyRequest().denyAll());
        return http.build();
    }
}
EOF

  cat <<'EOF' | render > "$name/src/main/resources/application.yml"
server:
  port: __PORT__

spring:
  application:
    name: __NAME__
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/__DB__
    username: ${DB_USER:sme_app}
    password: ${DB_PASSWORD}
  jpa:
    open-in-view: false
    hibernate:
      ddl-auto: validate
  flyway:
    enabled: true
  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS:localhost:9092}

management:
  endpoints:
    web:
      exposure:
        include: health,info
EOF
  write_dockerfile "$name" "$port"
}

gen_service user-management-service        8081 user_db         usermanagement        UserManagementApplication
gen_service invoice-management-service     8082 invoice_db      invoicemanagement     InvoiceManagementApplication
gen_service open-banking-service           8083 openbanking_db  openbanking           OpenBankingApplication
gen_service credit-risk-service            8084 creditrisk_db   creditrisk            CreditRiskApplication
gen_service financing-management-service   8085 financing_db    financingmanagement   FinancingManagementApplication
gen_service investor-bidding-service       8086 bidding_db      investorbidding       InvestorBiddingApplication
gen_service payment-repayment-service      8087 payment_db      paymentrepayment      PaymentRepaymentApplication
gen_service notification-service           8088 notification_db notification          NotificationApplication
gen_service administration-service         8089 admin_db        administration        AdministrationApplication

# ---------- API gateway ----------
name=api-gateway-service; port=8080
mkdir -p $name/src/main/java/$GP/gateway $name/src/main/resources
cat > $name/pom.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>com.smeinvoice</groupId>
        <artifactId>sme-invoice-marketplace</artifactId>
        <version>0.1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <artifactId>api-gateway-service</artifactId>
    <name>api-gateway-service</name>
    <dependencies>
        <dependency><groupId>com.smeinvoice</groupId><artifactId>common-lib</artifactId></dependency>
        <!-- Spring Cloud 2025.0 naming. If it fails to resolve, check the Spring Cloud Gateway release notes. -->
        <dependency><groupId>org.springframework.cloud</groupId><artifactId>spring-cloud-starter-gateway-server-webflux</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-test</artifactId><scope>test</scope></dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin><groupId>org.springframework.boot</groupId><artifactId>spring-boot-maven-plugin</artifactId></plugin>
        </plugins>
    </build>
</project>
EOF
cat > $name/src/main/java/$GP/gateway/ApiGatewayApplication.java <<'EOF'
package com.smeinvoice.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
EOF
cat > $name/src/main/resources/application.yml <<'EOF'
server:
  port: 8080

spring:
  application:
    name: api-gateway-service
  cloud:
    gateway:
      server:
        webflux:
          routes:
            - id: user-service
              uri: ${USER_SERVICE_URL:http://localhost:8081}
              predicates: [ "Path=/api/auth/**,/api/users/**" ]
            - id: invoice-service
              uri: ${INVOICE_SERVICE_URL:http://localhost:8082}
              predicates: [ "Path=/api/invoices/**" ]
            - id: open-banking-service
              uri: ${OPEN_BANKING_SERVICE_URL:http://localhost:8083}
              predicates: [ "Path=/api/banking/**" ]
            - id: credit-risk-service
              uri: ${CREDIT_RISK_SERVICE_URL:http://localhost:8084}
              predicates: [ "Path=/api/credit-risk/**" ]
            - id: financing-service
              uri: ${FINANCING_SERVICE_URL:http://localhost:8085}
              predicates: [ "Path=/api/financing/**" ]
            - id: bidding-service
              uri: ${BIDDING_SERVICE_URL:http://localhost:8086}
              predicates: [ "Path=/api/opportunities/**,/api/bids/**" ]
            - id: payment-service
              uri: ${PAYMENT_SERVICE_URL:http://localhost:8087}
              predicates: [ "Path=/api/payments/**,/api/loans/**,/api/repayments/**" ]
            - id: notification-service
              uri: ${NOTIFICATION_SERVICE_URL:http://localhost:8088}
              predicates: [ "Path=/api/notifications/**" ]
            - id: admin-service
              uri: ${ADMIN_SERVICE_URL:http://localhost:8089}
              predicates: [ "Path=/api/admin/**" ]
            - id: frontend
              uri: ${FRONTEND_URL:http://localhost:8090}
              predicates: [ "Path=/**" ]

management:
  endpoints:
    web:
      exposure:
        include: health,info
EOF
write_dockerfile $name $port

# ---------- frontend-web (Thymeleaf) ----------
name=frontend-web; port=8090
mkdir -p $name/src/main/java/$GP/frontend $name/src/main/resources/templates $name/src/main/resources/static
cat > $name/pom.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>com.smeinvoice</groupId>
        <artifactId>sme-invoice-marketplace</artifactId>
        <version>0.1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <artifactId>frontend-web</artifactId>
    <name>frontend-web</name>
    <dependencies>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-thymeleaf</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-test</artifactId><scope>test</scope></dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin><groupId>org.springframework.boot</groupId><artifactId>spring-boot-maven-plugin</artifactId></plugin>
        </plugins>
    </build>
</project>
EOF
cat > $name/src/main/java/$GP/frontend/FrontendWebApplication.java <<'EOF'
package com.smeinvoice.frontend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class FrontendWebApplication {
    public static void main(String[] args) {
        SpringApplication.run(FrontendWebApplication.class, args);
    }
}
EOF
cat > $name/src/main/java/$GP/frontend/HomeController.java <<'EOF'
package com.smeinvoice.frontend;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    @GetMapping("/")
    public String index() {
        return "index";
    }
}
EOF
cat > $name/src/main/resources/templates/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SME Invoice Marketplace</title>
</head>
<body>
    <h1>SME Invoice Financing Marketplace</h1>
    <p>Phase 1 skeleton: frontend-web is reachable through the API Gateway.</p>
</body>
</html>
EOF
cat > $name/src/main/resources/application.yml <<'EOF'
server:
  port: 8090
spring:
  application:
    name: frontend-web
management:
  endpoints:
    web:
      exposure:
        include: health,info
EOF
write_dockerfile $name $port

echo "Skeleton generated."