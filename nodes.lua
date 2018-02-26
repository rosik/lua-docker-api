local json = require('json')
local curl = require('http.client').new()
local utils = require('dockerapi.utils')

-- https://docs.docker.com/engine/api/v1.35/#operation/NodeList
local function list(url, unix_socket)
    local r = curl:get(
        string.format('%s/nodes', url),
        {unix_socket = unix_socket}
    )
    
    local body, err = utils.get_json_body(r)
    if err then
        return nil, err
    elseif r.status ~= 200 then
        return nil, body.message
    else
        return body
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/NodeInspect
local function inspect(url, unix_socket, id)
    local r = curl:get(
        string.format('%s/nodes/%s', url, id),
        {unix_socket = unix_socket}
    )
    
    local body, err = utils.get_json_body(r)
    if err then
        return nil, err
    elseif r.status ~= 200 then
        return nil, body.message
    else
        return body
    end
end

local nodes = {}

function nodes.init(url, unix_socket)
    return {
        list =    function(...) return list(url, unix_socket, ...) end,
        inspect = function(...) return inspect(url, unix_socket, ...) end,
    }
end

return nodes
