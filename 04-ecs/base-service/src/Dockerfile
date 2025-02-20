FROM python:3.9-slim

RUN useradd -m flask
RUN apt update -y && apt install curl -y

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

RUN chown -R flask:flask /app


ENV SERVICE1_URL=http://internal-devops-blueprint-internal-alb-1922529695.us-east-1.elb.amazonaws.com/service-1
ENV SERVICE2_URL=http://internal-devops-blueprint-internal-alb-1922529695.us-east-1.elb.amazonaws.com/service-2

CMD ["python", "app.py"]

EXPOSE 5000
