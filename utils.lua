local json = require('json')
local utils = {}

function utils.get_json_body(r)
    if r.status == 595 then
        return nil, r.reason
    end

    local headers = r.headers or {}
    local ct = headers['content-type']
    if ct == nil then
        return nil, "Server did not provide Content-Type headers"
    elseif ct ~= content_type then
        return nil, "Server replied with unexpected Content-Type '" .. ct .. "'"
    end

    return json.decode(r.body)
end

function utils.urlencode(str)
    if type(str) ~= 'string' then
        return ""
    end

    return str:gsub('\n', '\r\n')
        :gsub(
            '([^%w ])',
            function (c) return string.format('%%%02X', string.byte(c)) end
        )
        :gsub(' ', '+')
end

return utils
