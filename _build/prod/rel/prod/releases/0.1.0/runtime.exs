#use Mix.Config
import Config

#set include_erts: true

  #set include_src: false
  #set cookie: :"blah-blah"
#environment :win10 do
  #set include_erts: true
  #set include_src: false
  #set cookie: :"blah-blah"
#end

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :phxapp, Phxapp.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base



### Database Config for Render.com

#This info comes from https://devato.com/post/deploy-phoenix-app-to-render-com
database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

 config :db, DB.Repo,
 # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "50")
########################################################################







# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
     config :phxapp, Phxapp.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
