# Dockerfile

# Stage 1: Build with Gradle and OpenJDK 21
FROM gradle:7.6.1-jdk21 AS build

WORKDIR /app
COPY . .
RUN gradle build --no-daemon

# Stage 2: Runtime with Eclipse Temurin 21 JRE
FROM eclipse-temurin:21-jre

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user and set permissions
RUN addgroup --system appuser && \  
    adduser --system --ingroup appuser appuser

# Set working directory
WORKDIR /app

# Copy the build artifacts from Stage 1
COPY --from=build /app/build/libs/*.jar app.jar

# Set proper file permissions
RUN chown appuser:appuser app.jar

# Switch to non-root user
USER appuser

# Set the environment variable for the port
ENV PORT=8080

# Expose the port
EXPOSE $PORT

# Health check endpoint
HEALTHCHECK CMD curl --fail http://localhost:$PORT/actuator/health || exit 1

# JVM optimization parameters
ENTRYPOINT [ "java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar" ]