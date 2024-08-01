local function is_ok(status)
    return (status and 200 <= status and status < 300) or false
end

local function is_redirect(status)
    return (status and 300 <= status and status < 400) or false
end

return {
    is_ok=is_ok,
    is_redirect=is_redirect
}
