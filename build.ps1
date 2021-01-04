
Write-Host "Hello There!"
#!/usr/bin/env bash
# exit on error
#set -o errexit

# Initial setup
mix deps.get --only prod
$env:MIX_ENV = 'prod' 
mix compile $env:MIX_ENV 

# Compile assets
cd ./apps/phxapp/assets 
npm install
npm run deploy
cd ..
mix phx.digest
cd ../../
# Build the release and overwrite the existing release directory
mix release $env:MIX_ENV  --overwrite

##_build/prod/rel/prod/bin/prod eval "Render.Release.migrate"

Write-Host "App Built :)"