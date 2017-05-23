FROM ubuntu:16.04

MAINTAINER Sreehari Inukollu <isreehari@hotmail.com>

# Install libfuse2
RUN apt-get install -y libfuse2; \
	cd /tmp; \
	apt-get download fuse; \
	dpkg-deb -x fuse_* .; \
	dpkg-deb -e fuse_*; \
	rm fuse_*.deb; \
	echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst; \
	dpkg-deb -b . /fuse.deb; \
	dpkg -i /fuse.deb

# Install Java 8
RUN apt-get install -y openjdk-8-jdk

# Install Tomcat 7
RUN apt-get install -y tomcat8 tomcat8-admin
RUN sed -i "s#</tomcat-users>##g" /etc/tomcat8/tomcat-users.xml; \
	echo '  <role rolename="manager-gui"/>' >>  /etc/tomcat8/tomcat-users.xml; \
	echo '  <role rolename="manager-script"/>' >>  /etc/tomcat8/tomcat-users.xml; \
	echo '  <role rolename="manager-jmx"/>' >>  /etc/tomcat8/tomcat-users.xml; \
	echo '  <role rolename="manager-status"/>' >>  /etc/tomcat8/tomcat-users.xml; \
	echo '  <role rolename="admin-gui"/>' >>  /etc/tomcat8/tomcat-users.xml; \
	echo '  <role rolename="admin-script"/>' >>  /etc/tomcat8/tomcat-users.xml; \
	echo '  <user username="admin" password="SreeharI@123#" roles="manager-gui, manager-script, manager-jmx, manager-status, admin-gui, admin-script"/>' >>  /etc/tomcat8/tomcat-users.xml; \
	echo '</tomcat-users>' >> /etc/tomcat8/tomcat-users.xml

# Configure https
RUN sed -i "s#</Server>##g" /etc/tomcat8/server.xml; \
	sed -i "s#  </Service>##g" /etc/tomcat8/server.xml; \
	echo '    <Connector port="51251" protocol="HTTP/1.1" SSLEnabled="true" maxThreads="150" scheme="https" secure="true" clientAuth="false" sslProtocol="TLS" keystoreFile="/etc/tomcat8/cas.keystore" keystorePass="tomcat_admin" />' >> /etc/tomcat8/server.xml; \
	echo '  </Service>' >> /etc/tomcat8/server.xml; \
	echo '</Server>' >> /etc/tomcat8/server.xml

# Install CAS server
RUN cd /tmp; \
	wget https://developer.jasig.org/cas/cas-server-4.0.0-release.tar.gz; \
	tar xzvf cas-server-4.0.0-release.tar.gz; \
    cp cas-server-4.0.0/modules/cas-server-webapp-4.0.0.war /var/lib/tomcat8/webapps/cas.war; \
    service tomcat8 start; \
    sleep 10; \
    service tomcat8 stop; \
    cp cas-server-4.0.0/modules/cas-server-support-jdbc-4.0.0.jar /var/lib/tomcat8/webapps/cas/WEB-INF/lib

# Create CAS authentication DB
#RUN chmod 1777 /tmp; \
#	mysqld & \
#	sleep 5; \
#	echo "CREATE DATABASE cas" | mysql -uroot -pSreeharI@123#; \
#	echo "CREATE TABLE cas_users (id INT AUTO_INCREMENT NOT NULL, username VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL, password VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL, PRIMARY KEY (id), UNIQUE KEY (username))"| mysql -uroot -pSreeharI@123# -D cas; \
#	echo "INSERT INTO cas_users (username, password) VALUES ('guest', '084e0343a0486ff05530df6c705c8bb4')" | mysql -uroot -pSreeharI@123# -D cas; \
#	sleep 10

# Replace CAS deployerConfigContext.xml & install MySQL driver
ADD deployerConfigContext.xml /
ADD mysql-connector-java-5.1.42-bin.jar /
RUN mv deployerConfigContext.xml /var/lib/tomcat8/webapps/cas/WEB-INF/deployerConfigContext.xml; \
	mv mysql-connector-java-5.1.42-bin.jar /var/lib/tomcat8/webapps/cas/WEB-INF/lib

EXPOSE 8080
EXPOSE 51251

CMD chmod 1777 /tmp; \
#	mysqld_safe & \
#	service apache2 start; \
	[ ! -f /etc/tomcat8/cas.keystore ] && printf tomcat_admin\\ntomcat_admin\\n\\n\\n\\n\\n\\n\\ny\\ntomcat_admin\\ntomcat_admin\\n | keytool -genkey -alias tomcat -keyalg RSA -keystore /etc/tomcat8/cas.keystore; \
	service tomcat8 start; \
	/usr/sbin/sshd -D
