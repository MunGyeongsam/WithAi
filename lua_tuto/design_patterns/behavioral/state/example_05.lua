local download = { state = nil, progress = 0, message = "" }

local idle, downloading, complete, failed
idle = {}
function idle:handle(context, action)
    if action == "start" then
        context.progress = 0
        context.message = "started"
        context:set_state(downloading)
    end
end

downloading = {}
function downloading:handle(context, action)
    if action == "update" then
        context.progress = context.progress + 50
        context.message = "downloading"
    elseif action == "finish" then
        context.progress = 100
        context.message = "complete"
        context:set_state(complete)
    elseif action == "fail" then
        context.message = "failed"
        context:set_state(failed)
    end
end

complete = {}
function complete:handle(context, action) context.message = "already complete" end

failed = {}
function failed:handle(context, action) context.message = "retry required" end

function download:set_state(next_state) self.state = next_state end
function download:handle(action) self.state:handle(self, action) end

download:set_state(idle)
download:handle("start")
download:handle("update")
assert(download.state == downloading and download.progress == 50)
download:handle("finish")
assert(download.state == complete and download.progress == 100)
download:handle("start")
assert(download.state == complete and download.message == "already complete")
print(download.state == complete, download.progress, download.message)
