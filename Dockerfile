FROM google/cloud-sdk:alpine

ADD backup.sh /app/backup.sh

RUN apk add --no-cache \
  bash \
  mongodb-tools \
  && chmod +x /app/backup.sh

ENTRYPOINT /app/backup.sh
