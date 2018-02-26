local json = require('json')
local curl = require('http.client').new()
local utils = require('dockerapi.utils')

-- https://docs.docker.com/engine/api/v1.35/#operation/TaskList
local function list(url, unix_socket, filters)
    local r = curl:get(
        string.format('%s/tasks?filters=%s', url, utils.urlencode(json.encode(filters))),
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

local tasks = {}

function tasks.init(url, unix_socket)
    return {
        list =    function(...) return list(url, unix_socket, ...) end,
    }
end

return tasks
