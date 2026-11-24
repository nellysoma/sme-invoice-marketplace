# Build from repo root:  docker build -f frontend-web/Dockerfile -t sme/frontend-web .
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn -B -q -pl frontend-web -am -DskipTests package

FROM eclipse-temurin:17-jre
RUN useradd -r -u 1001 appuser
WORKDIR /app
COPY --from=build /workspace/frontend-web/target/*.jar app.jar
USER appuser
EXPOSE 8090
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
