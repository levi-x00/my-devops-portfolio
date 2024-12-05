FROM python:3.9-alpine

# Add a non-root user
RUN adduser -D flask

# Update the package index and install necessary dependencies
RUN apk update && apk add --no-cache curl build-base libffi-dev openssl-dev

# Set the working directory
WORKDIR /app

# Copy the requirements file and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Set permissions and switch to the non-root user
RUN chown -R flask:flask /app
USER flask

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
