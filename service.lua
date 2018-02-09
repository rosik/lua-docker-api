local json = require('json')
local curl = require('http.client').new()
local HOST = 'localhost'
local SOCK = '/var/run/docker.sock'
local API = 'v1.35'

local function assert_json(r)
    local ct = r.headers['content-type']
    if ct == nil then
        error("Server did not provide Content-Type headers")
    elseif ct ~= 'application/json' then
        error("Server replied with unexpected Content-Type '" .. ct .. "'")
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceList
local function ls()
    local r = curl:get(
        string.format('http://%s/%s/services', HOST, API),
        {
            unix_socket = SOCK,
        }
    )
    
    assert_json(r)
    if r.status == 200 then
        return json.decode(r.body)
    else
        error({r.status, json.decode(r.body)})
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceInspect
local function inspect(id)
    local r = curl:get(
        string.format('http://%s/%s/services/%s', HOST, API, id),
        {
            unix_socket = SOCK,
        }
    )
    
    assert_json(r)
    if r.status == 200 then
        return json.decode(r.body)
    elseif r.status == 404 then
        return nil
    else
        error({r.status, json.decode(r.body)})
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceCreate
local function create(params)
    local r = curl:post(
        string.format('http://%s/%s/services/create', HOST, API),
        json.encode(params),
        {
            unix_socket = SOCK,
            headers = {['Content-Type'] = 'application/json'}
        }
    )
    
    assert_json(r)
    if r.status == 201 then
        return json.decode(r.body)
    else
        error({r.status, json.decode(r.body)})
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceUpdate
local function update(id, version, params)
    -- local version = inspect(id).Version.Index
    local r = curl:post(
        string.format('http://%s/%s/services/%s/update?version=%d', HOST, API, id, version),
        json.encode(params),
        {
            unix_socket = SOCK,
            headers = {['Content-Type'] = 'application/json'}
        }
    )
    
    assert_json(r)
    if r.status == 200 then
        return json.decode(r.body)
    else
        error({r.status, json.decode(r.body)})
    end
end

return {
    ls = ls,
    inspect = inspect,
    create = create,
    update = update,
}
