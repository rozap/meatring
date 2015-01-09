Meatring
========


### a cross between chat.meatspac.es and a threaded forum, backed by a kademlia distributed hash table


What you need to do: 
  1. install [elixir](http://elixir-lang.org/install.html)
  2. clone this repo
  3. find a node to join the network of, or you could create your own network. 
    1.  try ``` mix run --no-halt ``` to build your own network. This will give you your own meatring node in the kademlia net. If you point your browser to your.ip.address:8081 you will see the meatring web interface. Note that the 8081 port is configurable via the mix config. when it starts it will print ```seed_id``` and ```seed_location``` out that can be given to another node via mix config, and that other node will bootstrap off of the first node.
  4. this is all highly experimental, half implemented and won't work. 
  
