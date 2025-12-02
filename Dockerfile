#Use the official Python base image
FROM python:3.13-alpine

#Set the working directory inside the container
WORKDIR /app

#Copy the requirements file into the container
COPY requirements.txt .

#Install the Python dependencies (Flask)
RUN pip install --no-cache-dir -r requirements.txt

#Copy the application code into the container
COPY app.py .

#Expose the port that the Flask app runs on
EXPOSE 5000

#Define the command to run the application
CMD ["python", "app.py"]