# Use Tomcat as a base image
FROM tomcat:9.0

# Remove default Tomcat application
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy build .war image to application webapps server location
COPY demo.war /usr/local/tomcat/webapps/demo.war

# Expose 8080 port to serv application
EXPOSE 8080
