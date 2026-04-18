# Stage 1: Build
# Using gradle wrapper so no need to get gradle
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /expensetracker

# Copy gradlew and required files (for caching)
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

RUN chmod +x gradlew

# Download dependencies (cache layer)
RUN ./gradlew build -x test --no-daemon || true

# Copy source
COPY src src

# Build
RUN ./gradlew clean build -x test --no-daemon

# Stage 2: Run the application with a lightweight JRE  
FROM eclipse-temurin:17-jre-alpine
WORKDIR /expensetracker  

COPY --from=builder /expensetracker/build/libs/*.jar app.jar 

# Run the JAR  
ENTRYPOINT ["java", "-jar", "app.jar"]  