FROM python:3.9-slim

RUN useradd -m flask
RUN apt update -y && apt install curl -y

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

RUN chown -R flask:flask /app
USER flask

CMD ["python", "app.py"]

EXPOSE 5002
