# Użyj oficjalnego obrazu Tomcat jako obrazu bazowego
FROM tomcat:latest

# Opcjonalnie: Usuń domyślne aplikacje Tomcat (np. aplikacje przykładowe), nie jest to wymagane
RUN rm -rf /usr/local/tomcat/webapps/*

# Skopiuj wybudowany plik .war aplikacji do katalogu webapps serwera Tomcat
COPY demo.war /usr/local/tomcat/webapps/demo.war

# Tomcat nasłuchuje na porcie 8080, nie trzeba eksponować go, jeśli używasz docker run z opcją -P lub -p,
# ale dobrą praktyką jest zadeklarowanie tego w Dockerfile
EXPOSE 8080

# Uruchomienie Tomcata w trybie foreground (domyślne polecenie CMD w obrazie Tomcat spełnia tę rolę)