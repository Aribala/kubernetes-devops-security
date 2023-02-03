FROM openjdk:8-jdk-alpine
RUN apk --no-cache add bash
RUN apk --no-cache add curl
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]