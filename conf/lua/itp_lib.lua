local mymodule = {}

function mymodule.git_pull(branch)
	local cmd = ngx.var.basepath .. "/conf/scripts/nginx_shell_script.sh pull " .. branch
	os.execute(cmd)
	ngx.log(ngx.INFO, cmd)
end

function mymodule.createInstance(branch, port)
	local cmd = ngx.var.basepath .. "/conf/scripts/nginx_shell_script.sh create " .. branch .. " " .. port
	os.execute(cmd)
	ngx.log(ngx.INFO, cmd)
end

function mymodule.clean()
	local cmd = os.getenv("CODE_FARM_ROOT") .. "/conf/scripts/nginx_shell_script.sh clean "
	os.execute(cmd)
	ngx.log(ngx.INFO, cmd)
end

return mymodule
