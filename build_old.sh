
echo "Building App"
#!/usr/bin/env bash
# exit on error
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
#npm install --prefix ./assets
echo "Debug 0"
cd ./apps/phxapp/assets && npm install #&& npm run deploy && cd ...
echo "Debug 1"
#npm run deploy --prefix ./assets
#npm run deploy --prefix #./apps/phxapp/assets
npm run deploy #--prefix #./apps/phxapp/assets
echo "Debug 2"
cd ..
mix phx.digest
cd ../../
echo "Debug 3"
# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite
echo "Finished - have a nice day! :)"