# Build stage - using jammy for arm64 support
FROM maven:3.9-eclipse-temurin-11-jammy AS builder
WORKDIR /app
COPY myapp/pom.xml .
COPY myapp/src ./src
RUN mvn clean package -DskipTests

# Runtime stage - using slim instead of alpine for arm64 support
FROM eclipse-temurin:11-jre-jammy

# Create non-root user for security
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -m appuser

WORKDIR /app

# Copy JAR from build stage
COPY --from=builder /app/target/*.jar app.jar

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port (optional, for future use)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

