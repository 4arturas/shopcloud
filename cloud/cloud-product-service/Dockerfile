FROM openjdk:21-jdk-slim
VOLUME /tmp
EXPOSE 8080
COPY target/ /app/target/
RUN mv /app/target/product-service-0.0.1-SNAPSHOT.jar /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
