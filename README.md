# notice
tom3k/django:v1.0 은 sqlite3를 사용하고 있습니다. 해당 [branch](https://github.com/parkbyungnam/Django_Docker_website/tree/v1.0) 에서 자세한 부분을 참고하세요.

[master](https://github.com/parkbyungnam/Django_Docker_website) 에서는 이미 가지고 있는 장고 프로젝트를 **컨테이너 이미지로 만드는 방법**과 **도커에서 장고 컨테이너를 실행하는 법**을 기술하고 있습니다.

## index
- Overview
- Requirement
- Project structure
- Django Site map
- Use with Docker
- review
- References

# 1. Overview

a. 컨테이너를 통해 배포하는 것이 목적

b. 서버와 DB를 분리

c. 컨테이너 이미지를 docker hub 에 올리기

d. docker hub에 올라간 이미지로 컨테이너 실행 확인하기


## Run Project v1.0

```
$ docker run -it -p 8000:8000 tom3k/django:v1.0 
```
![게시판1](https://user-images.githubusercontent.com/57394605/126055060-ab19f891-7c99-407c-af68-cfac1baf1ce0.png)

![게시판2](https://user-images.githubusercontent.com/57394605/126055064-1e62fbec-c008-40f8-8697-df92398935a3.png)



## Run Project v1.1

```
$ docker run --rm -d \         
    --name db \
    -e POSTGRES_DB=djangodb \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=toor \
    postgres:12.7

$ docker run -it --rm \
    -p 8000:8000 \
    --link db \
    -e DJANGO_DB_HOST=db \
    -e DJANGO_DEBUG=True \
    tom3k/django:v1.1 python3 manage.py migrate

$ docker run -it --rm \
    -p 8000:8000 \
    --link db \
    -e DJANGO_DB_HOST=db \
    -e DJANGO_DEBUG=True \
    tom3k/django:v1.1 python3 manage.py runserver

```






# 2. Requirement

|**Name**|**version**|
|--|--|
|Python|3.7.6|
|Django|3.1.3|
|nginx|latest|
|gunicorn|20.1.0|

자세한 사항은 requirements.txt 를 참고하세요.

# 3. Project structure

![시스템구성도](https://user-images.githubusercontent.com/57394605/126054858-c83e1dcd-7f5e-49bb-bfc4-7359f409c1b9.jpg)

Nginx 와 Gunicorn 을 사용하여 높은 성능을 보장하고 많은 요청이 올때마다 병렬적인 처리로 병목현상을 방지하여 안정화된 서버 구축.

DB는 로컬볼륨과 마운트하여 백업


# 4. Django Site map

```
/common/
       /login         : 로그인 페이지
       /signup         : 회원가입 페이지

/pybo/
     /(게시글번호)         : 맛집 게시글 페이지
     /question/create/   : 맛집 게시글 입력 페이지

/admin                    : 관리자 페이지

```

# 5. Use with Docker


## Ⅰ. Create Dockerfile & docker-compose.yaml
```
#Dockerfile

FROM python:3.7.6

WORKDIR /app

COPY requirements.txt ./

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000
```

```
# docker-compose.yaml

version: '3'

volumes:
  postgres_data: {}

services:
  db:
    image: postgres:12.7
    volumes:
      - postgres_data:/var/lib/postgres/data
    environment:
      - POSTGRES_DB=djangodb
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=toor

  django:
    build:
      context: .
      dockerfile: ./compose/django/Dockerfile-dev
    volumes:
      - ./:/app/
    command: ["python", "manage.py", "runserver", "0:8000"]
    environment:
     - DJANGO_DB_HOST=db
    depends_on:
      - db
    restart: always
    ports:
      - 8000:8000
```
프로젝트 최상단 디렉토리에서 Dockerfile 과 docker-compose.yaml 작성

## Ⅱ. edit settings.py

장고 프로젝트에서 settings.py를  수정해야 합니다.

```
~
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DJANGO_DB_NAME', 'djangodb'),
        'USER': os.environ.get('DJANGO_DB_USERNAME', 'root'),
        'PASSWORD': os.environ.get('DJANGO_DB_PASSWORD', 'toor'),
        'HOST': os.environ.get('DJANGO_DB_HOST', 'localhost'),
        'PORT': os.environ.get('DJANGO_DB_PORT', '5432'),
    }
}
~
```


## Ⅲ. build

```
$ docker build --tag (yourID)/(name):(tag) . 
```

![image](https://user-images.githubusercontent.com/57394605/126055565-accb320d-85a1-45e0-b8c5-1ce530eff9aa.png)

![image](https://user-images.githubusercontent.com/57394605/126055618-f1f30df2-8e98-4fd9-b78c-8007c93c0813.png)



## Ⅳ. run DB

```
docker run --rm -d \         
    --name db \
    -e POSTGRES_DB=djangodb \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=toor \
    postgres:12.7
```

![image](https://user-images.githubusercontent.com/57394605/126055715-1832a1bf-f367-45be-9189-0e146b590754.png)


## Ⅴ. migrate
```
docker run -it --rm \
    -p 8000:8000 \
    --link db \
    -e DJANGO_DB_HOST=db \
    -e DJANGO_DEBUG=True \
tom3k/django:v1.1 python3 manage.py migrate
```

![image](https://user-images.githubusercontent.com/57394605/126055740-4423d466-5594-4d7d-804c-241d429430b9.png)


## Ⅵ. runserver

```
docker run -it --rm \
    -p 8000:8000 \
    --link db \
    -e DJANGO_DB_HOST=db \
    -e DJANGO_DEBUG=True \
tom3k/django:v1.1 python3 manage.py runserver
```
![image](https://user-images.githubusercontent.com/57394605/126055748-d7aa4629-1823-4aa7-8812-bb9fc4a106b8.png)


![게시판1](https://user-images.githubusercontent.com/57394605/126055060-ab19f891-7c99-407c-af68-cfac1baf1ce0.png)

![게시판2](https://user-images.githubusercontent.com/57394605/126055064-1e62fbec-c008-40f8-8697-df92398935a3.png)


## Ⅶ. docker hub

```
docker login

docker push (yourID)/(name):(tag)
```

![image](https://user-images.githubusercontent.com/57394605/126055407-bd8efefd-993f-44df-a331-0fbc72900f4c.png)



# References
- [점프 투 장고](https://wikidocs.net/book/4223)
- [44bits 기술 블로그](https://www.44bits.io/ko/post/almost-perfect-development-environment-with-docker-and-docker-compose)
- [postgres offical images](https://hub.docker.com/_/postgres)
- [시작하세요! 도커/쿠버네티스](http://www.yes24.com/Product/Goods/84927385)