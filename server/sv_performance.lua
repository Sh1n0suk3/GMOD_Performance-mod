local function RemoveHooksAndTimers()
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("Think", "CheckSchedules")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    timer.Remove("CheckHookTimes")
    timer.Remove("HostnameThink")
end

local function OptimizeAnimations()
    local function returnNil() return nil end
    hook.Add("MouthMoveAnimation", "PerformanceModOptimization", returnNil)
    hook.Add("GrabEarAnimation", "PerformanceModOptimization", returnNil)
end

local function OptimizeMemory()
    local memoryCommands = {
        {"mem_max_heapsize", "131072"},
        {"mem_max_heapsize_dedicated", "131072"},
        {"mem_min_heapsize", "131072"},
        {"sv_hibernate_think", "1"},
        {"sv_maxunlag", "1"},
        {"sv_maxupdaterate", "66"},
        {"sv_minupdaterate", "10"},
        {"sv_client_min_interp_ratio", "1"},
        {"sv_client_max_interp_ratio", "2"},
        {"sv_maxcmdrate", "66"},
        {"sv_mincmdrate", "10"},
        {"sv_minrate", "20000"},
        {"sv_maxrate", "0"},
        {"decalfrequency", "10"},
        {"sv_parallel_sendsnapshot", "1"},
        {"sv_querycache_stats", "1"}
    }

    for _, cmd in ipairs(memoryCommands) do
        RunConsoleCommand(unpack(cmd))
    end
end

local function ApplyServerOptimizations()
    if not GetConVar("performancemod_enabled"):GetBool() then return end

    RemoveHooksAndTimers()

    if GetConVar("performancemod_server_optimize_animations"):GetBool() then
        OptimizeAnimations()
    end

    if GetConVar("performancemod_server_optimize_memory"):GetBool() then
        OptimizeMemory()
    end
end

hook.Add("Initialize", "PerformanceModInitialize", function()
    ApplyServerOptimizations()

    cvars.AddChangeCallback("performancemod_enabled", ApplyServerOptimizations)
    cvars.AddChangeCallback("performancemod_server_optimize_animations", ApplyServerOptimizations)
    cvars.AddChangeCallback("performancemod_server_optimize_memory", ApplyServerOptimizations)
end)

util.AddNetworkString("PerformanceModApplyServer")
net.Receive("PerformanceModApplyServer", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    ApplyServerOptimizations()
    net.Start("PerformanceModApplyServer")
    net.Send(ply)
end)

concommand.Add("performancemod_apply_server", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end

    ApplyServerOptimizations()
    print("Server-side performance optimizations applied.")
end)