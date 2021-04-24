FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN pip install --no-cache-dir -r /app/requirements.txt

CMD ["/bin/bash"]
ENTRYPOINT EXCLUDE_URLS=".*github.com" python crawler/crawler.py https://vitkhab.github.io/search_engine_test_site/
