Meatring
========


What you need to do: 
  1. install [elixir](http://elixir-lang.org/install.html)
  2. clone this repo
  3. find a node to join the network of, or you could created your own network. 
    1.  try --seed_id c7d42cff15360c60316921d734440b21 --seed_location http://107.170.246.36:9090
  4. run ```mix meatring.start -b http://your.ip.address:<port>
  5. This will give you your own meatring node in the kademlia net. If you point your browser to your.ip.address:8081 you will see the meatring web interface. Note that the 8081 port is configurable via the -b, --bind option. 
  6. ``` mix meatring.start --help ``` when in doubt. 
  
  
