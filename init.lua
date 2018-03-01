local containers = require('dockerapi.containers')
local networks =   require('dockerapi.networks')
local swarm =      require('dockerapi.swarm')
local nodes =      require('dockerapi.nodes')
local services =   require('dockerapi.services')
local tasks =      require('dockerapi.tasks')

local dockerapi = {}

function dockerapi.init(url, unix_socket)
    return {
        containers = containers.init(url, unix_socket),
        networks =   networks.init(url, unix_socket),
        swarm =      swarm.init(url, unix_socket),
        nodes =      nodes.init(url, unix_socket),
        services =   services.init(url, unix_socket),
        tasks =      tasks.init(url, unix_socket),
    }
end

return dockerapi
