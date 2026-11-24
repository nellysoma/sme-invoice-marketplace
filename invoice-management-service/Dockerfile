# Build from repo root:  docker build -f invoice-management-service/Dockerfile -t sme/invoice-management-service .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn -B -q -pl invoice-management-service -am -DskipTests package

FROM eclipse-temurin:17-jre
RUN useradd -r -u 1001 appuser
WORKDIR /app
COPY --from=build /workspace/invoice-management-service/target/*.jar app.jar
USER appuser
EXPOSE 8082
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
