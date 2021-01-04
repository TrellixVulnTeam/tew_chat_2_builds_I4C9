
echo "Hello There! :) - Building App"
#!/usr/bin/env bash
# exit on error
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
cd ./apps/phxapp/assets && npm install
npm run deploy
cd ..
mix phx.digest
cd ../../
# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite

#Run the scripts to migrate the database
_build/prod/rel/prod/bin/prod eval "DB.Release.migrate"
echo "App Built <3"