local json = require('json')
local curl = require('http.client').new()
local utils = require('dockerapi.utils')

-- https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
local function create(url, unix_socket, name, params)
    local r = curl:post(
        string.format('%s/containers/create?name=%s', url, name),
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

-- https://docs.docker.com/engine/api/v1.35/#operation/ContainerInspect
local function inspect(url, unix_socket, name)
    local r = curl:get(
        string.format('%s/containers/%s/json', url, name),
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

-- https://docs.docker.com/engine/api/v1.35/#operation/ContainerStart
local function start(url, unix_socket, name)
    local r = curl:post(
        string.format('%s/containers/%s/start', url, name),
        nil,
        {unix_socket = unix_socket}
    )
    
    if r.status == 204 then
        return true
    elseif r.status == 304 then
        return false
    else
        local body, err = utils.get_json_body(r)
        if err then
            return false, err
        else
            return false, body.message
        end
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/ContainerStop
local function stop(url, unix_socket, name)
    local r = curl:post(
        string.format('%s/containers/%s/stop', url, name),
        nil,
        {unix_socket = unix_socket}
    )

    if r.status == 204 then
        return true
    elseif r.status == 304 then
        return false
    else
        local body, err = utils.get_json_body(r)
        if err then
            return false, err
        else
            return false, body.message
        end
    end
end

local containers = {}

function containers.init(url, unix_socket)
    return {
        create =  function(...) return create(url, unix_socket, ...) end,
        inspect = function(...) return inspect(url, unix_socket, ...) end,
        start =   function(...) return start(url, unix_socket, ...) end,
        stop =    function(...) return stop(url, unix_socket, ...) end,
    }
end

return containers
