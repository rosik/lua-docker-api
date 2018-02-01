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

local function create(name, image, env, labels)
    local r = curl:post(
        string.format('http://%s/%s/containers/create?name=%s', HOST, API, name),
        json.encode({
            Image = tostring(image),
            Env = env,
            Healthcheck = {Test = {"NONE"}},
            Labels = labels,
            CheckDuplicate = true,
        }),
        {
            unix_socket = SOCK,
            headers = {['Content-Type'] = 'application/json'}
        }
    )
    
    assert_json(r)
    if r.status == 201 then
        return json.decode(r.body)
    else
        error(json.decode(r.body)['message'])
    end
end

local function inspect(name)
    local r = curl:get(
        string.format('http://%s/%s/containers/%s/json', HOST, API, tostring(name)),
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
        error(json.decode(r.body)['message'])
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/ContainerStart
local function start(name)
    local r = curl:post(
        string.format('http://%s/%s/containers/%s/start', HOST, API, tostring(name)),
        nil,
        {
            unix_socket = SOCK,
        }
    )
    
    if r.status == 204 then
        return true
    elseif r.status == 304 then
        return false
    else
        assert_json(r)
        error(json.decode(r.body)['message'])
    end
end

-- https://docs.docker.com/engine/api/v1.35/#operation/ContainerStop
local function stop(name)
    local r = curl:post(
        string.format('http://%s/%s/containers/%s/stop', HOST, API, tostring(name)),
        nil,
        {
            unix_socket = SOCK,
        }
    )

    if r.status == 204 then
        return true
    elseif r.status == 304 then
        return false
    else
        assert_json(r)
        error(json.decode(r.body)['message'])
    end
end

return {
    create = create,
    inspect = inspect,
    start = start,
    stop = stop,
}
