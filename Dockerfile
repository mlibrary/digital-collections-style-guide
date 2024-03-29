FROM node:16.6
ARG UNAME=app
ARG UID=1000
ARG GID=1000
EXPOSE 5555

LABEL maintainer="roger@umich.edu"

# #RUN npm install -g npm@7.20.3
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  vim-tiny libxml2 libxml2-dev libxml2-utils libxslt1.1 xsltproc


RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
USER $UNAME

WORKDIR /app
RUN [ "/bin/date" ]
RUN [ "/bin/ls", "/app" ]
COPY package.json /app
RUN [ "/usr/bin/find", "/app", "-type", "f" ]
# RUN sleep 600
RUN npm install
COPY . /app
RUN npm run build-js
RUN npm run build-sass
CMD [ "npm", "run", "proxy" ]
