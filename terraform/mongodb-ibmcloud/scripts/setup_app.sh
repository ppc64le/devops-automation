#!/bin/bash -xe 
# This scripts sets up the main mean app in the corect directory
# builds and renders the angular scripts
# installs forever to simplifyy running application
EXTERNAL_STORAGE="${EXTERNAL_STORAGE:-/mnt}"
mkdir -p $EXTERNAL_STORAGE 
mv  /tmp/scripts/app $EXTERNAL_STORAGE
APP_DIR=$EXTERNAL_STORAGE"/app"
ENV_FILE=$EXTERNAL_STORAGE"/app/database-api/env.sh"
# make build
cd $APP_DIR/database-api/
export $(xargs < $ENV_FILE)
export ME_CONFIG_MONGODB_ADMINUSERNAME="${API_ROOT_DB_USERNAME}"
export ME_CONFIG_MONGODB_ADMINPASSWORD="${API_ROOT_DB_PASSWORD}"
export ME_CONFIG_BASICAUTH_USERNAME="${API_UI_USERNAME}" 
export ME_CONFIG_BASICAUTH_PASSWORD="${API_UI_PASSWORD}"
export VCAP_APP_PORT="${API_UI_APP_PORT}"
export VCAP_APP_HOST="0.0.0.0"
#export ME_CONFIG_MONGODB_SERVER="localhost"
export ME_CONFIG_MONGODB_PORT="${API_DB_PORT}"
export ME_CONFIG_MONGODB_URL="mongodb://${API_DB_USERNAME}:${API_DB_PASSWORD}@127.0.0.1:${API_DB_PORT}/${API_DB_NAME}?ssl=false"
if [ ! -d $APP_DIR/mongo-express ]; then
        cd $APP_DIR
        git clone https://github.com/mongo-express/mongo-express.git
        cd mongo-express
        git checkout tags/v0.54.0
        npm install forever -g
fi
cd $APP_DIR/mongo-express
yarn
echo "Starting application ..."
forever start -l mongo-express-forever.log -o mongo-express-out.log -e mongo-express-err.log app.js
