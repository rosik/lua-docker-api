local json = require('json')
local curl = require('http.client').new()
local utils = require('dockerapi.utils')

-- https://docs.docker.com/engine/api/v1.35/#operation/NetworkCreate
local function create(url, unix_socket, params)
    local r = curl:post(
        string.format('%s/networks/create', url),
        json.encode(params),
        {
            unix_socket = unix_socket,
            headers = {['Content-Type'] = 'application/json'}
        }
    )
    
    local body, err = utils.get_json_body(r)
    if err then
        return nil, err
    elseif r.status ~= 201 then
        return nil, body.message
    else
        return body
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/NetworkInspect
local function inspect(url, unix_socket, name)
    local r = curl:get(
        string.format('%s/networks/%s', url, name),
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

-- https://docs.docker.com/engine/api/v1.35/#operation/NetworkConnect
local function connect(url, unix_socket, name, container)
    local r = curl:post(
        string.format('http://%s/%s/networks/%s/connect', HOST, API, tostring(name)),
        json.encode({
            Container = tostring(container),
        }),
        {
            unix_socket = unix_socket,
            headers = {['Content-Type'] = 'application/json'}
        }
    )
    
    if r.status == 200 then
        return true
    else
        local body, err = utils.get_json_body(r)
        if err then
            return false, err
        else
            return false, body.message
        end
    end
end

local networks = {}

function networks.init(url, unix_socket)
    return {
        create =  function(...) return create(url, unix_socket, ...) end,
        inspect = function(...) return inspect(url, unix_socket, ...) end,
        connect = function(...) return connect(url, unix_socket, ...) end,
    }
end

return networks
