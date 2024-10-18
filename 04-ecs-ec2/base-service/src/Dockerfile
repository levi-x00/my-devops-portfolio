FROM python:3.9-slim

RUN useradd -m flask
RUN apt update -y && apt install curl -y

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

ENV SERVICE1_URL=http://service-1.devops-portfolio.internal
ENV SERVICE2_URL=http://service-2.devops-portfolio.internal

RUN chown -R flask:flask /app
USER flask

CMD ["python", "app.py"]

EXPOSE 5000
