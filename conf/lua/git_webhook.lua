ngx.req.read_body()
local data  = string.gsub(ngx.req.get_body_data(),"%s+", "")

local cjson = require "cjson"

local hook = cjson.decode(data)

if hook.ref == nil then
	return
end

local branch = string.sub(hook.ref, 12)

local lib = require "itp_lib"

lib.git_pull(branch)

ngx.log(ngx.INFO, "Webhook received, update local reposotiry. Branch:" .. branch)
ngx.say(branch)
