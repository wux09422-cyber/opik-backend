# Use Gradle 8.7

FROM gradle:8.7-jdk21 AS build

WORKDIR /app

# Copy the gradle files
COPY gradle gradle
COPY settings.gradle .
COPY build.gradle .

# Download the dependencies
RUN gradle build --no-daemon

# Copy the source code
COPY src ./src

# Build the application
RUN gradle build --no-daemon

# Start a new stage from the base image
FROM openjdk:21-jdk

WORKDIR /app

# Copy the built jar file from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Health check command
HEALTHCHECK CMD curl --fail http://localhost:8080/health || exit 1

# Run the application
CMD ["java", "-jar", "app.jar"]