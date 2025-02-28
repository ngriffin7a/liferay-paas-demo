FROM maven:3.8.3-openjdk-17

COPY . /opt/liferay/cmschat
WORKDIR /opt/liferay/cmschat

RUN ["mvn", "clean", "install"]

EXPOSE 9090

CMD ["java", "-jar", "build/cmschat-0.0.1-SNAPSHOT.jar"]