# Stage 1: Build the WAR using Maven
FROM maven:3.8-openjdk-11 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Deploy to Tomcat
FROM tomcat:9-jdk11
RUN rm -rf /usr/local/tomcat/webapps/ROOT*
COPY --from=builder /app/target/mayabazr-showroom.war /usr/local/tomcat/webapps/ROOT.war
RUN cd /usr/local/tomcat/webapps && unzip -q ROOT.war -d ROOT && rm ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
