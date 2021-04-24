FROM python:3.6.0-alpine

WORKDIR /app/ui
ADD . /app

RUN pip install --no-cache-dir -r /app/requirements.txt

ENV FLASK_APP=ui.py

CMD ["gunicorn", "ui:app", "-b 0.0.0.0"]
