FROM python:3.8-slim

ENV PATH="/scripts:${PATH}"

# Security: Update base packages first to patch vulnerabilities
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libc-dev \
    pkg-config \
    default-mysql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /requirements.txt

RUN pip install --upgrade pip && pip3 install -r /requirements.txt

RUN mkdir /GiftcardSite

COPY ./GiftcardSite /GiftcardSite

WORKDIR /GiftcardSite

COPY ./scripts /scripts

RUN chmod +x /scripts/*

RUN mkdir -p /vol/web/media
RUN mkdir -p /vol/web/static

RUN adduser -D django-app

RUN chown -R django-app:django-app /vol

RUN chmod -R 755 /vol/web

RUN chown -R django-app:django-app /GiftcardSite

USER django-app

CMD ["entrypoint.sh"]
