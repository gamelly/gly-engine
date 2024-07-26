local function fps_counter(fps_limit, fps_obj, uptime)
    if uptime >= fps_obj.period + 1000 then
        fps_obj.period = uptime
        fps_obj.total = fps_obj.count
        fps_obj.count = 0

        if fps_obj.drop_count == 0 then
            return true
        end

        if fps_obj.total + fps_obj.drop_count > fps_limit then
            fps_obj.falls = 0
            return true
        end

        fps_obj.falls = fps_obj.falls + 1
        
        if fps_obj.drop_time < fps_obj.falls then
            fps_obj.falls = 0
            return false
        end
    end
    
    fps_obj.count = fps_obj.count + 1
    fps_obj.delta = uptime - fps_obj.passed
    fps_obj.passed = uptime

    return true
end

local function install(std, game, application, config_fps)
    local index = 1
    std = std or {}
    application = application or {}
    application.internal = application.internal or {}
    config_fps.inverse_list = {}

    local fps_obj = {total=0,count=0,period=0,passed=0,delta=0,falls=0,drop=0}
    fps_obj.drop_time=application.config and application.config.fps_time or 1
    fps_obj.drop_count=application.config and application.config.fps_drop or 2

    while index <= #config_fps.list do
        config_fps.inverse_list[config_fps.list[index]] = index
        index = index + 1
    end

    application.internal.fps_controler=function(milis)
        local index = config_fps.inverse_list[game.fps_max]
        game.milis = event.uptime()
        game.fps = fps_obj.total
        game.dt = fps_obj.delta 
        if not fps_counter(game.fps_max, fps_obj, game.milis) then
            if index < #config_fps.list then
                game.fps_max = config_fps.list[index + 1]
            end
        end
        return config_fps.time[index]
    end

    return {
        fps_controler = fps_controler
    }
end

local P = {
    install=install
}

return P
