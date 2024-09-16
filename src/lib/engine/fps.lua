local function fps_counter(fps_limit, fps_tracker, current_time)
    if current_time >= fps_tracker.last_check + 1000 then
        fps_tracker.last_check = current_time
        fps_tracker.total_fps = fps_tracker.frame_count
        fps_tracker.frame_count = 0

        if fps_tracker.drop_count == 0 then
            return true
        end

        if fps_tracker.total_fps + fps_tracker.drop_count > fps_limit then
            fps_tracker.fall_streak = 0
            return true
        end

        fps_tracker.fall_streak = fps_tracker.fall_streak + 1
        
        if fps_tracker.fall_streak >= fps_tracker.allowed_falls then
            fps_tracker.fall_streak = 0
            return false
        end
    end
    
    fps_tracker.frame_count = fps_tracker.frame_count + 1
    fps_tracker.time_delta = current_time - fps_tracker.last_frame_time
    fps_tracker.last_frame_time = current_time

    return true
end

local function install(std, game, application, config_fps)
    local index = 1
    
    application.internal = application.internal or {}
    config_fps.inverse_list = {}

    local fps_obj = {total_fps=0,frame_count=0,last_check=0,last_frame_time=0,time_delta=0,fall_streak=0,drop=0}
    fps_obj.allowed_falls=application.config and application.config.fps_time or 1
    fps_obj.drop_count=application.config and application.config.fps_drop or 2

    while index <= #config_fps.list do
        config_fps.inverse_list[config_fps.list[index]] = index
        index = index + 1
    end

    application.internal.fps_controler=function(milis)
        local index = config_fps.inverse_list[game.fps_max]
        game.milis = event.uptime()
        game.fps = fps_obj.total_fps
        game.dt = fps_obj.time_delta 
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
