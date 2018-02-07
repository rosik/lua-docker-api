local json = require('json')
local curl = require('http.client').new()
local HOST = 'localhost'
local SOCK = '/var/run/docker.sock'
local API = 'v1.35'

local function create(name)
    local r = curl:post(
        string.format('http://%s/%s/networks/create', HOST, API),
        json.encode({
            Name = tostring(name),
            Driver = 'overlay',
            CheckDuplicate = true,
        }),
        {
            unix_socket = SOCK,
            headers = {['Content-Type'] = 'application/json'}
        }
    )
    
    if r.headers['content-type'] ~= 'application/json' then
        error("Server replied with unexpected Content-Type '" .. r.headers['content-type'] .. "'")
    end

    if r.status == 201 then
        return json.decode(r.body)
    else
        error(json.decode(r.body)['message'])
    end
end

local function inspect(name)
    local r = curl:get(
        string.format('http://%s/%s/networks/%s', HOST, API, tostring(name)),
        {
            unix_socket = SOCK,
        }
    )
    
    if r.headers['content-type'] ~= 'application/json' then
        error("Server replied with unexpected Content-Type '" .. r.headers['content-type'] .. "'")
    end

    if r.status == 200 then
        return json.decode(r.body)
    elseif r.status == 404 then
        return nil
    else
        error(json.decode(r.body)['message'])
    end
end

local function connect(name, container)
    local r = curl:post(
        string.format('http://%s/%s/networks/%s/connect', HOST, API, tostring(name)),
        json.encode({
            Container = tostring(container),
        }),
        {
            unix_socket = SOCK,
            headers = {['Content-Type'] = 'application/json'}
        }
    )
    

    if r.status == 200 then
        return true
    else
        if r.headers['content-type'] ~= 'application/json' then
            error("Server replied with unexpected Content-Type '" .. r.headers['content-type'] .. "'")
        end
        error(json.decode(r.body)['message'])
    end
end

return {
    create = create,
    inspect = inspect,
    connect = connect,
}
