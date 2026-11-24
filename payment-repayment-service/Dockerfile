# Build from repo root:  docker build -f payment-repayment-service/Dockerfile -t sme/payment-repayment-service .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn -B -q -pl payment-repayment-service -am -DskipTests package

FROM eclipse-temurin:17-jre
RUN useradd -r -u 1001 appuser
WORKDIR /app
COPY --from=build /workspace/payment-repayment-service/target/*.jar app.jar
USER appuser
EXPOSE 8087
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
