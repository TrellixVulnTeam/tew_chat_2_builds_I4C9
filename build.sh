
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

#Run the scripts to migrate the database:
#NOTE - once I got it working via Tew_Chat_1_1, other 'apps' (clones of TewChat) pointing to the same database were nolonger being accepted, and causing errors. It said one of the problems could be that the tables one is trying to migrate were set up by a different 'library'. Probably the other app (Tew_Chat_1_1).
#So, I have commented out the migration script activation command here, since we don't technically need it, right now.
#To do further migrations, of coure we /would/ need to fix this problem.
#My idea is to go into TewChat_1_1 on the Render Dashboad, drop the database in the shell there via mix.ecto.drop
#Then run the migration script again underneath here, when redeploying TewChat
#But for now, I'll leave it, and help clean the house :)
#_build/prod/rel/prod/bin/prod eval "DB.Release.migrate"
echo "App Built <3"