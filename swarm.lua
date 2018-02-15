local json = require('json')
local curl = require('http.client').new()
local utils = require('dockerapi.utils')
local HOST = 'localhost'
local SOCK = '/var/run/docker.sock'
local API = 'v1.35'

local function inspect()
    local r = curl:get(
        string.format('http://%s/%s/swarm', HOST, API),
        {
            unix_socket = SOCK,
        }
    )
    
    utils.assert_json(r)
    if r.status == 200 then
        return json.decode(r.body)
    elseif r.status == 404 then
        return nil
    else
        error(json.decode(r.body)['message'])
    end
end

return {
    inspect = inspect,
}
