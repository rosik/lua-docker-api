local network = require('dockerapi.network')
local container = require('dockerapi.container')
local service = require('dockerapi.service')
local node = require('dockerapi.node')
local tasks = require('dockerapi.tasks')
local swarm = require('dockerapi.swarm')

return {
	network = network,
	container = container,
	service = service,
	node = node,
	tasks = tasks,
	swarm = swarm,
}
