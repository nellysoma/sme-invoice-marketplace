# Build from repo root:  docker build -f notification-service/Dockerfile -t sme/notification-service .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn -B -q -pl notification-service -am -DskipTests package

FROM eclipse-temurin:17-jre
RUN useradd -r -u 1001 appuser
WORKDIR /app
COPY --from=build /workspace/notification-service/target/*.jar app.jar
USER appuser
EXPOSE 8088
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
