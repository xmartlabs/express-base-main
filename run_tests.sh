SECRET_KEY=mysecret docker-compose run -e NODE_ENV=testing base-api node_modules/.bin/sequelize db:drop
SECRET_KEY=mysecret docker-compose run -e NODE_ENV=testing base-api node_modules/.bin/sequelize db:create
SECRET_KEY=mysecret docker-compose run -e NODE_ENV=testing base-api node_modules/.bin/sequelize db:migrate
SECRET_KEY=mysecret docker-compose run -e NODE_ENV=testing base-api npm install
SECRET_KEY=mysecret docker-compose run -e NODE_ENV=testing base-api npm test
