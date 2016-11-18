local dockers = ngx.shared.dockers

--retrive repo and branch
local repo = ""
local branch = ""

local args = ngx.req.get_uri_args()
local ck = require "resty.cookie"
local cookie = ck:new()
local needNewDocker = false
local json = require "cjson"

for key, val in pairs(args) do

	if key == "__branch__" then
		branch = val
		--get branch from param, set it in to cookie
		cookie:set({
			key = "__branch__",
			value = branch,
			path = "/",
			secure = true,
			httpoly = true,
		})
		needNewDocker = true
	elseif key == "__repo__" then
		repo = val
                cookie:set({
                        key = "__repo__",
                        value = repo,
                        path = "/",
                        secure = true,
                        httpoly = true,
                })		
		needNewDocker = true
	end
end
-- if branch is empty, try to get it from cookie
if branch == "" then
	local field, err = cookie:get("__branch__")
	if field then
		branch = field
	end

	local field, err = cookie:get("__repo__")
	if field then
		repo = field
	end
end

ngx.log(ngx.INFO, "rewrite=> branch[" .. branch .. "] repo[".. repo .. "]")

local dIdx = ngx.md5(repo .. branch)
local dockers = ngx.shared.dockers
local setting = nil

local lib = require("itp_lib")
-- if the branch did not exists anywhere, use default
if (branch == "" or branch == nil or branch == "develop") then
	-- retrive default info
	local default = dockers:get("default")
	if default == nil then
		--if infomation is nil, run docker
		setting = {
			branch = "develop",
			port = 10443,
			repo = ""
		}
		dockers:set("default", json.encode(setting))
		lib.createInstance(setting.branch, setting.port)
	else
		setting = json.decode(default)
	end
else
	--if there is no data, create new docker instance
	local sjson = dockers:get(dIdx)
	local port = dockers:get("lastport")
	-- ngx.log(ngx.INFO, "add " .. repo .. branch  .. "[" .. dIdx .. "]:[" .. (port or "nil") .. "] to storage.")

	if (sjson == nil or sjson == '')  then
		if (port == nil or port == '')  then 
			port = 20000
		end
		port = port + 1
		dockers:set("lastport", port)


		setting = {
			branch = branch,
			port = port,
			repo = ""
		}
		dockers:set(dIdx, json.encode(setting))
		lib.createInstance(setting.branch, setting.port)
	else
		setting = json.decode(sjson)
	end
end

local argx = ""
if ngx.var.args ~= nil then
	argx = ngx.var.args
end

ngx.var.upstream = ngx.var.scheme .. "://" ..     ngx.var.host .. ":" .. setting.port .. ngx.var.uri .. "?"  .. argx

ngx.log(ngx.INFO, "rewrite to:" .. ngx.var.upstream)
