# Build from repo root:  docker build -f credit-risk-service/Dockerfile -t sme/credit-risk-service .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn -B -q -pl credit-risk-service -am -DskipTests package

FROM eclipse-temurin:17-jre
RUN useradd -r -u 1001 appuser
WORKDIR /app
COPY --from=build /workspace/credit-risk-service/target/*.jar app.jar
USER appuser
EXPOSE 8084
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
