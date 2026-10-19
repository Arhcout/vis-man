local function open_man(page)
    vis:command('o')
    vis.win:map(vis.modes.NORMAL, "<Enter>", function()
        vis.win:close(true)
    end)
    vis.win:set_syntax("man")

    vis:command("<man -c " .. page)
    local content = vis.win.file:content(0, vis.win.file.size)
    if content == "" then
        vis.win:close()
        return
    end

    -- Parse man file (remove backspaces)
    local filtered = ""
    local i = 1
    while i <= #content - 1 do
        local next_c = content:sub(i+1,i+1)
        if next_c  == '\b' then
            i = i + 2
        else
            filtered = filtered .. content:sub(i,i)
            i = i + 1
        end
    end

    vis.win.file:delete(0, vis.win.file.size)
    vis.win.file:insert(0, filtered)

    vis.win:draw()
end

vis.events.subscribe(vis.events.INIT, function()
    vis:map(vis.modes.VISUAL, "gM", function()
        local page = vis.win.file:content(vis.win.selection.range)
        open_man(page)
    end)
    vis:command_register("Man", function(argv, force, win, selection, range)
        local arg = table.concat(argv, " ")
        open_man(arg)
    end , "Open a man page into a vis buffer. Man <page>")
end)
