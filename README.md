# 0. index

# 1. Overview

a. 컨테이너를 통해 배포하는 것이 목적
b. 서버와 DB를 분리
c. 컨테이너 이미지를 docker hub 에 올리기
d. docker hub에 올라간 이미지로 컨테이너 실행 확인하기

![게시판1](https://user-images.githubusercontent.com/57394605/126055060-ab19f891-7c99-407c-af68-cfac1baf1ce0.png)

![게시판2](https://user-images.githubusercontent.com/57394605/126055064-1e62fbec-c008-40f8-8697-df92398935a3.png)



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
       /login         : 로그인페이지
       /signup         : 회원가입페이지

/pybo/
     /(게시글번호)         : 맛집 게시글페이지
     /question/create/   : 맛집 게시글 입력 페이지

```

# 5. Use Docker

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



```
$ docker build --tag tom3k/django:v1.1 . 
```

![image](https://user-images.githubusercontent.com/57394605/126055407-bd8efefd-993f-44df-a331-0fbc72900f4c.png)
