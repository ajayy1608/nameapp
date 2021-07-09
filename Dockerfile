FROM python:3.9-alpine

WORKDIR /app

COPY nameapp.py .

RUN pip3 install flask --no-cache-dir

USER nobody

CMD ["python", "nameapp.py"]