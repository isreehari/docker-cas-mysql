docker-cas-mysql
============================

```
docker pull isreehari/docker-cas-mysql
```

Run with 8080, and 51251 ports opened:
```
docker run -d -p 49162:8080 -p 49163:51251 -p 49164:3306 isreehari/docker-cas-mysql
```

Login the CAS server https://localhost:49163/cas/login with following credential:
```
username: guest
password: guest
```

Open Tomcat web admin http://localhost:49162/manager/html with following credential:
```
username: admin
password: admin
```
