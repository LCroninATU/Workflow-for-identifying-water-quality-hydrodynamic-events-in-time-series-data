---
title: "Setting Up RStudio in Docker"
author: "Your Name"
date: "`r Sys.Date()`"
output: 
  html_document:
    toc: true
    toc_float: true
    theme: united
    highlight: tango
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, eval = FALSE)
```

# Running using Docker

This document outlines the process of setting up and running an RStudio environment using Docker. Docker provides a way to create consistent, reproducible environments across different machines, making it ideal for collaborative research and development.

## 1 Prerequisites

-   Install **Windows Subsystem for Linux** - [Download here](https://learn.microsoft.com/en-us/windows/wsl/install)

-   Install **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop)

-   Open up a windows command prompt session (press the Windows+r keys, in the run box that pops up, type cmd, click OK.)

-   At the command prompt, change directory (using the "cd" command) to the directory where you've downloaded the git repository to. This directory should contain the dockerfile.

## 2 Building the docker image

-   Build a Docker image using the dockerfile in the repository: (Note, enure that Rstudio is not running when you do this as the build may not execture correctly when Rstudio is running.)
-   Perform the build by entering the command below at the command prompt. (Note: don't forget the final `.` in the command, this `.` is not a full stop but an integral part of the command)

`docker build -t rstudio-project .`

-   This process may take several minutes as Docker downloads base images and installs all required dependencies.

## 3 Running the docker container

-   Once the image is built, you can run a container based on it: when you run this container, you will be able to set up the Rstudio environment within it an execute the project code.

-   To run the docker container, type or paste the following command at the command prompt and hit enter.

`docker run -d -p 8787:8787 -e PASSWORD=yourpassword -e USER=rstudio --name rstudio-container rstudio-project`

-   This will create a docker "container" that can be accessed by user "rstudio". The container name will be "rstudio-container" and it will be created from the docker image you created in Step 2. Replace `yourpassword` with a password of your choice.

## 4 Opening the project in the docker container

-   Open your web browser

-   Enter <http://localhost:8787> in the address bar.

-   Log in with:

    -   Username: rstudio
    -   Password: yourpassword (the one you specified in step 3)

-   When the Rstudio session starts, click File-\>Open Project and browse to the location where the Project file is located (this will be the same directory as the dockerfile).

-   When the project opens, run the code as required.

## 5 Working with the Docker Container

Here are some common commands for managing your Docker container:

\`\`\`{# List running containers} docker ps

# Stop the container

docker stop rstudio-container

# Start a stopped container

docker start rstudio-container

# Remove a container (must be stopped first)

docker rm rstudio-container

# Remove an image

docker rmi rstudio-project \`\`\`
