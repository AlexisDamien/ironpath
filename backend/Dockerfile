# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /workspace

COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN chmod +x gradlew && ./gradlew --no-daemon dependencies

COPY config config
COPY src src
RUN ./gradlew --no-daemon clean bootJar

FROM eclipse-temurin:21-jre-jammy AS runtime

LABEL org.opencontainers.image.title="IronPath Backend"
LABEL org.opencontainers.image.description="API Spring Boot de l'application IronPath"

RUN groupadd --system --gid 10001 ironpath \
    && useradd --system --uid 10001 --gid ironpath --create-home ironpath

WORKDIR /app
COPY --from=build --chown=ironpath:ironpath /workspace/build/libs/*.jar /app/ironpath-backend.jar

USER ironpath
EXPOSE 8080

ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -Dfile.encoding=UTF-8"

HEALTHCHECK --interval=10s --timeout=5s --start-period=40s --retries=12 \
  CMD curl --fail --silent --show-error http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/ironpath-backend.jar"]
