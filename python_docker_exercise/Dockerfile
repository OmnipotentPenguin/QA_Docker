#   an argument for the python version
#   by default this is for version 3.6.8, but it can be modified
ARG PYTHON_VERSION=3.6.8

# the base image to build from which is ready to run
# Python code immediately
FROM python:${PYTHON_VERSION}

# the working directory for docker instructions has
# been changed to where our application is going
# to be installed
WORKDIR /opt/python-server

# copy the correct python script to the current working directory
COPY ./python-server-${PYTHON_VERSION}.py app.py

# copy the index.html to the install folder
# the install folder is where the python application will be running
# all content from the install will be served because of this
# when a request is made to the server, the index.html will
# be served by default
COPY index.html .

# this executes a shell command to alter the contents of the index.html
# the webpage will have different content depending on the
# version of Python that is running
RUN sed -i "s/{{PYTHON_VERSION}}/${PYTHON_VERSION}/g" index.html

# the application runs on port 9000
# port 9000 on TCP has been exposed here for documentation purposes
EXPOSE 9000

# an entrypoint has been set here
# the Python binary is executed, with the correct script as an argument
ENTRYPOINT ["/usr/local/bin/python", "app.py"]
