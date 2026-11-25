FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /build

COPY pom.xml .

RUN --mount=type=cache,target=/root/.m2 \
    mvn -B dependency:go-offline


COPY src ./src
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine AS runtime

RUN apk add --no-cache tzdata ca-certificates curl && \
    addgroup -S app && adduser -S app -G app

WORKDIR /app

COPY --from=builder /build/target/*.jar /app/app.jar

RUN chown -R app:app /app
USER app

ENV APP_PORT=8080
ENV SPRING_PROFILES_ACTIVE=default

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]