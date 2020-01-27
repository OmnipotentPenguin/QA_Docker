#!/bin/bash
echo "Please enter a name for the directory of the project:"
read dir_name
rm -r $dir_name
mkdir $dir_name
cd $dir_name
​
echo "Please enter a name for the repo:"
read repo_name
​
echo "Please enter a github repo to clone:"
read repo
​
echo "Please enter the git branch to clone:"
read branch
​
git clone --single-branch --branch $branch $repo $repo_name
​
echo "Please enter a name for the project:"
read project_name
​
echo "Please enter the port your project needs to run on:"
read project_port
​
echo "Please enter the project context-path:"
read context_path
​
echo "Please enter a name for the network:"
read network
containers=$(docker network inspect -f '{{ range $key, $value := .Containers }}{{ printf "%s\n" $key}}{{ end }}' $network)
echo ${containers}
docker network disconnect $network ${containers}
docker network rm $network
docker network create $network
​
valid=0
​
while [ ${valid} -eq 0 ]
do
    echo "Does your repo need a mysql database? y/n"
    read mysql
    case "${mysql}" in
        "Y"|"y") echo "What is the database called?"
	     read db_name
	     echo "Please enter a name for the container:"
	     read cont_name
	     docker stop $cont_name
	     docker rm $cont_name
	     docker container run --name $cont_name --network $network -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=$db_name -d mysql
	     let valid=1;;
        "n"|"N") echo "No database created"
    	     let valid=1;;
        *) "Please enter a vaild response";;
    esac
done
​
cd $repo_name
if ! [ -f "Dockerfile" ]
then
    touch Dockerfile
    echo ' FROM maven:latest AS build
COPY . /build
WORKDIR /build
RUN mvn clean package -DskipTests
​
FROM openjdk:8-jdk-alpine AS run
WORKDIR /opt/notes
COPY --from=0 /build/target/*.jar app.jar
ENTRYPOINT ["/usr/bin/java", "-jar", "app.jar"] ' > Dockerfile
fi
​
echo "Please enter the port your project will be accessed from:"
read project_access_port
​
docker stop $project_name
docker rm $project_name
​
echo "If relevant, would you like to separate out the front-end?"
read static_separate
if [ ${static_separate}="y" ] || [ ${static_separate}="Y" ]
then
    STATIC=./src/main/resources/static
    echo hello
    if [ -d ${STATIC} ]
    then
	echo hello
        mv $STATIC ..
        cp Dockerfile ../static
	docker build -t $project_name .
	cd ../static
	echo ' FROM nginx
COPY . /var/www
COPY nginx.conf /etc/nginx/nginx.conf ' > Dockerfile
	touch nginx.conf
	echo ' events {}
http {
        server {
                listen 80;
        root /var/www/;
        index index.html;
                include /etc/nginx/mime.types;
        location / {
                        try_files $uri $uri/ /;
        }
                location /'${context_path}' {
                        proxy_pass http://'${project_name}':'${project_port}';
                }
        }
}' > nginx.conf
​
	docker run --network $network --name $project_name -d -p $project_access_port:$project_port $project_name
        echo "What port would you like to access the front-end on?"
	read  f_e_port
	echo "Please enter a name for the front-end container:"
	read f_e_name
	docker build -t $f_e_name .
	docker stop $f_e_name
	docker rm $f_e_name
        docker run --network $network --name $f_e_name -d -p $f_e_port:80 $f_e_name
    fi
else
    docker build -t $project_name .
    docker run --network $network --name $project_name -d -p $project_access_port:$project_port $project_name
fi
​
echo "Project - ${project_name} - is running on container port ${project_port} and can be accessed from ${project_access_port}"
