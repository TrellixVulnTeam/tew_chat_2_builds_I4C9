###### Whether a Chat Tab has been Clicked Or Not (AKA Load Messaging Screen, or Main Screen) #########

defmodule Phxapp.RenderMainScreen do

  defstruct [
    render_value: 0
  ]

end


defmodule Phxapp.RenderRealChat do

  defstruct [
    render_value: 1
  ]

end

#############################

###### Chat List Objects #####

#AKA Fake Chat
defmodule Phxapp.FakeChat do

  defstruct [
    value: -1
  ]

end

#AKA Private Chat
defmodule Phxapp.PrivateChat do

  defstruct [
    value: 1
  ]

end

#AKA Group Chat
defmodule Phxapp.GroupChat do

  defstruct [
    value: 2
  ]

end

####### Inter Message Types ######

defmodule Phxapp.NewMessage do

  defstruct [
    value: 1
  ]

end

defmodule Phxapp.NewPrivateChat do

  defstruct [
    value: 2
  ]

end

defmodule Phxapp.NewGroupChat do

  defstruct [
    value: 3
  ]

end

####################################
