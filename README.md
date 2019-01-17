Varnish VCL configuration. It depends which configuration you will choose. IP addresses we are fetching from *.yml files.
  We explicitly set the static IP address to each Docker service.
  
  **Nginx:**
  
    ```.host = "172.28.1.11";```    
    ```.port = "8000";```    
    
  **Apache:**
  
    ```.host = "172.28.1.10";```    
    ```.port = "8080";```
    
How it looks like in the working environment. File - default.vcl
```
backend default {
    # IP was taken from nginx.yml, it is Nginx container IP address
    # nginx
    .host = "172.28.1.11";
    .port = "8000";

    # IP was taken from apache.yml, it is Apache container IP address
    # apache
    #.host = "172.28.1.10";
    #.port = "8080";
}    
```

#### The environment with Apache as the backend server for Varnish

- to build Docker images from scratch.

    ```docker-compose -f apache.yml up --build -d``` - run each container as a daemon. It means that the containers would run 
    in the background completely detached from the shell.
    
    ```docker-compose -f apache.yml up --build ``` - run containers with an interactive shell. It means that all log 
    information from all the containers will be output to the shell (in case if a container is configured to output log information).
    
- startup existing configuration, in case, if all images have been already built

    ```docker-compose -f apache.yml up -d``` - run each container as a daemon.
    
    ```docker-compose -f apache.yml up``` - run containers with an interactive shell.
    
    ```docker-compose -f apache.yml start``` - start all the containers.
    
    ```docker-compose -f apache.yml stop``` - stop all the containers.
    
- by default, Apache will be started with PHP 5.6 version. 
But you have the possibility to switch between PHP versions (5.6 | 7.0 | 7.2) with a help of shell scripts. 
They reside inside the ```app_container``` running container by this path ```/tmp/shell```. 
For PHP 7.2, if you need to install deprecated 'mcrypt' extension, instructions on how to do that you can find inside Apache Dockerfile

- to enable Xdebug - please check ```/tmp/shell``` folder inside the container (via a shell script). Container name ```app_container```

#### The environment with Nginx as the backend server for Varnish 

- to build Docker images from scratch.

    ```docker-compose -f nginx.yml up --build -d ``` - run each container as a daemon. It means that the containers would run 
    in the background completely detached from the shell.
    
    ```docker-compose -f nginx.yml up --build``` - run containers with an interactive shell. It means that all log information 
    from all the containers will be output to the shell (in case if a container is configured to output log information).
    
- startup existing configuration, in case, if all images have been already built

    ```docker-compose -f nginx.yml up -d``` - run each container as a daemon.
    
    ```docker-compose -f nginx.yml up``` - run containers with an interactive shell.
     
    ```docker-compose -f nginx.yml start``` - start all the containers.
    
    ```docker-compose -f nginx.yml stop``` - stop all the containers.
    
By default, the ```nginx.yml``` configuration will use PHP-FPM 7.0. But you have the possibility to switch between 
PHP-FPM versions (5.6 | 7.0 | 7.1 | 7.2).
 
To switch to another PHP-FPM version, for example, 7.1 you have to:

- build new PHP-FPM Docker image with a help of this command ```docker image build -t phpfpm_container:7.1 .``` 
 
- use this newly created Docker image inside ```nginx.yml``` configuration.
 
Replace this part, which is used by default
```    
    phpfpm:
        build: ./docker_configuration/php-fpm/7.0
```
to this one, after building a new PHP-FPM Docker image
```    
    phpfpm:
        image: phpfpm_container:7.1
```
This procedure is the same for each PHP version.

- to enable Xdebug - you have to uncomment this line 
```;zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20160303/xdebug.so```

    file ```/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini```
    
    inside ```phpfpm_container``` container and restart php-fpm service.