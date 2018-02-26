local json = require('json')
local curl = require('http.client').new()
local utils = require('dockerapi.utils')

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceList
local function list(url, unix_socket)
    local r = curl:get(
        string.format('%s/services', url),
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

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceInspect
local function inspect(url, unix_socket, id)
    local r = curl:get(
        string.format('%s/services/%s', url, id),
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

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceCreate
local function create(url, unix_socket, params)
    local r = curl:post(
        string.format('%s/services/create', url),
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

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceUpdate
local function update(url, unix_socket, id, version, params)
    -- local version = inspect(id).Version.Index
    local r = curl:post(
        string.format('%s/services/%s/update?version=%d', url, id, version),
        json.encode(params),
        {
            unix_socket = unix_socket,
            headers = {['Content-Type'] = 'application/json'}
        }
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

local services = {}

function services.init(url, unix_socket)
    return {
        list =    function(...) return list(url, unix_socket, ...) end,
        inspect = function(...) return inspect(url, unix_socket, ...) end,
        create =  function(...) return create(url, unix_socket, ...) end,
        update =  function(...) return update(url, unix_socket, ...) end,
    }
end

return services
