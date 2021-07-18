FROM python:3.7.6

WORKDIR /app

COPY requirements.txt ./

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["gunicorn", "--bind", "0:8000", config.wsgi:application"]
#CMD ["python3", "manage.py", "runserver", "0:8000"]