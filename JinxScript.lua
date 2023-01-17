async_http.init('raw.githubusercontent.com','/Prisuhm/JinxScript/main/JinxScript.lua',function(a)
    local err = select(2,load(a))
    if err then
        util.toast("Script failed to download. Please try again later. If this continues to happen then manually update via github.")
    return end
    local f = io.open(filesystem.scripts_dir()..SCRIPT_RELPATH, "wb")
    f:write(a)
    f:close()
    util.toast("Successfully downloaded JinxScript. :)")
    util.restart_script()
end)
async_http.dispatch()
repeat 
    util.yield()
until response
util.keep_running()