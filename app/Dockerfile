FROM node:14

ARG RDS_PASSWORD
ARG RDS_DATABASE_ADDRESS
# Create app directory
WORKDIR /app

# Bundle app source
COPY . .

RUN npm install
RUN sed -i "s/RDS_PASSWORD_PLACEHOLDER/${RDS_PASSWORD}/g" queries.js
RUN sed -i "s/RDS_DATABASE_ADDRESS_PLACEHOLDER/${RDS_DATABASE_ADDRESS}/g" queries.js

EXPOSE 80
CMD [ "node", "index.js" ]