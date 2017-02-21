extends Node

static func setup(server, clients):
	GlobalConfig.set("test_server", server)
	GlobalConfig.set("test_clients", clients)

static func test_impersonate():
	var clients = GlobalConfig.get("test_clients")
	assert(clients.size()>0)
	var client = clients[clients.size()-1] # Last client is the bad guy!

	var id = client.get_tree().get_network_unique_id()
	var rem = 0
	assert(id != 1)
	assert(client._has_peer)

	# Will pose as other client to server
	for c in client.get_children():
		if c.id != id:
			# Client change set network mode
			rem = c.get_network_remote()
			c.set_network_remote(c.get_tree().get_network_unique_id())
			c.rpc_id(1, "client_message", var2bytes(str(id) + " posing as " + str(c.id)))
			# Client restore network mode for future tests
			c.set_network_remote(rem)

	# Will pose as server to other clients
	rem = client.get_network_remote()
	client.set_network_remote(client.get_tree().get_network_unique_id())
	for c in client.get_children():
		if c.id != id:
			client.rpc_id(c.id, "server_message", var2bytes(str(id) + " posing as server"))
	client.set_network_remote(rem)

	# Will pose as a different client to other clients
	var ids = []
	for c in client.get_children():
		ids.append(c.id)
	
	for c in client.get_children():
		if c.id != id:
			# Client change set network mode
			rem = c.get_network_remote()
			c.set_network_remote(c.get_tree().get_network_unique_id())
			for other in ids:
				if other != c.id and other != id: # I'm sneaky, I'll send to all except the real owner
					c.rpc_id(other, "client_message", var2bytes(str(id) + " posing as " + str(c.id)))
			# Client restore network mode for future tests
			c.set_network_remote(rem)