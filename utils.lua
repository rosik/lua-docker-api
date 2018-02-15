local function assert_json(r)
	if r.status == 595 then
		error(r.reason)
	end

    local ct = r.headers['content-type']
    if ct == nil then
        error("Server did not provide Content-Type headers")
    elseif ct ~= 'application/json' then
        error("Server replied with unexpected Content-Type '" .. ct .. "'")
    end
end

return {
	assert_json = assert_json,
}
