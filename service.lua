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

-- https://docs.docker.com/engine/api/v1.35/#operation/ServiceCreate
local function create(name, image, env, labels)
    local r = curl:post(
        string.format('http://%s/%s/services/create', HOST, API),
        json.encode({
            Name = name,
            Labels = labels,
            TaskTemplate = {
                ContainerSpec = {
                    Image = tostring(image),
                    Hostname = name,
                    Env = env,
                    Healthcheck = {Test = {"NONE"}},
                    CheckDuplicate = true,
                },
            },
            Networks = {{Target = 'tnt_net'}},
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
        error({r.status, json.decode(r.body)})
    end
end

return {
    ls = ls,
    create = create,
}
