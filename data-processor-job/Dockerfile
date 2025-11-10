# Use an official lightweight Python image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies
# We copy this first to leverage Docker's layer caching
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# NOTE: This is a JOB, not a SERVICE.
# We do NOT use CMD or ENTRYPOINT.
# Cloud Run Jobs will specify the command to run.