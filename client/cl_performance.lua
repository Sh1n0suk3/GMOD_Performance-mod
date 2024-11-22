local performance_commands = {
    {"gmod_mcore_test", "1"},
    {"mem_max_heapsize", "131072"},
    {"mem_max_heapsize_dedicated", "131072"},
    {"mem_min_heapsize", "131072"},
    {"threadpool_affinity", "64"},
    {"mat_queue_mode", "2"},
    {"mat_powersavingsmode", "0"},
    {"r_queued_ropes", "1"},
    {"r_threaded_renderables", "1"},
    {"r_threaded_particles", "1"},
    {"r_threaded_client_shadow_manager", "1"},
    {"cl_threaded_client_leaf_system", "1"},
    {"cl_threaded_bone_setup", "1"},
    {"ai_expression_optimization", "1"},
    {"fast_fogvolume", "1"},
    {"mat_managedtextures", "0"}
}

local network_commands = {
    {"cl_forcepreload", "1"},
    {"cl_lagcompensation", "1"},
    {"cl_timeout", "3600"},
    {"cl_smoothtime", "0.05"},
    {"cl_localnetworkbackdoor", "1"},
    {"cl_cmdrate", "66"},
    {"cl_updaterate", "66"},
    {"cl_interp_ratio", "2"},
    {"net_maxpacketdrop", "0"},
    {"net_chokeloop", "1"},
    {"net_compresspackets", "1"},
    {"net_splitpacket_maxrate", "50000"},
    {"net_compresspackets_minsize", "4097"},
    {"net_maxroutable", "1200"},
    {"net_maxfragments", "1200"},
    {"net_maxfilesize", "64"},
    {"net_maxcleartime", "0"},
    {"rate", "1048576"}
}

local other_commands = {
    {"snd_mix_async", "1"},
    {"snd_async_fullyasync", "1"},
    {"snd_async_minsize", "0"},
    {"sv_forcepreload", "1"},
    {"studio_queue_mode", "1"},
    {"filesystem_max_stdio_read", "64"},
    {"in_usekeyboardsampletime", "1"},
    {"r_radiosity", "4"},
    {"mat_frame_sync_enable", "0"},
    {"mat_framebuffercopyoverlaysize", "0"},
    {"lod_TransitionDist", "2000"},
    {"filesystem_unbuffered_io", "0"}
}

CreateClientConVar("performancemod_network_enabled", "1", true, false, "Enable network optimizations")
CreateClientConVar("performancemod_other_enabled", "1", true, false, "Enable other optimizations")
CreateClientConVar("performancemod_fps_boost", "0", true, false, "Enable FPS boost")

local function RunCommands(commands)
    for _, cmd in ipairs(commands) do
        RunConsoleCommand(unpack(cmd))
    end
end

local function ApplyClientSettings()
    if GetConVar("performancemod_fps_boost"):GetBool() then
        RunCommands(performance_commands)
    else
        RunCommands({
            {"gmod_mcore_test", "0"},
            {"mat_queue_mode", "-1"},
            {"r_queued_ropes", "0"},
            {"r_threaded_renderables", "0"},
            {"r_threaded_particles", "0"},
            {"r_threaded_client_shadow_manager", "0"},
            {"cl_threaded_client_leaf_system", "0"},
            {"cl_threaded_bone_setup", "0"},
            {"ai_expression_optimization", "0"},
            {"fast_fogvolume", "0"},
            {"mat_managedtextures", "1"}
        })
    end

    if GetConVar("performancemod_network_enabled"):GetBool() then
        RunCommands(network_commands)
    else
        RunCommands({
            {"cl_forcepreload", "0"},
            {"cl_lagcompensation", "1"},
            {"cl_timeout", "30"},
            {"cl_smoothtime", "0.1"},
            {"cl_localnetworkbackdoor", "0"},
            {"cl_cmdrate", "30"},
            {"cl_updaterate", "20"},
            {"cl_interp_ratio", "2"},
            {"net_maxpacketdrop", "5000"},
            {"net_chokeloop", "0"},
            {"net_compresspackets", "1"},
            {"net_splitpacket_maxrate", "1048576"},
            {"net_compresspackets_minsize", "1024"},
            {"net_maxroutable", "1200"},
            {"net_maxfragments", "1260"},
            {"net_maxfilesize", "16"},
            {"net_maxcleartime", "4"},
            {"rate", "196608"}
        })
    end

    if GetConVar("performancemod_other_enabled"):GetBool() then
        RunCommands(other_commands)
    else
        RunCommands({
            {"snd_mix_async", "0"},
            {"snd_async_fullyasync", "0"},
            {"snd_async_minsize", "262144"},
            {"sv_forcepreload", "0"},
            {"studio_queue_mode", "0"},
            {"filesystem_max_stdio_read", "32"},
            {"in_usekeyboardsampletime", "0"},
            {"r_radiosity", "2"},
            {"mat_frame_sync_enable", "1"},
            {"mat_framebuffercopyoverlaysize", "128"},
            {"lod_TransitionDist", "800"},
            {"filesystem_unbuffered_io", "1"}
        })
    end
end

timer.Simple(1, ApplyClientSettings)

cvars.AddChangeCallback("performancemod_network_enabled", function() timer.Simple(0.1, ApplyClientSettings) end, "PerformanceMod")
cvars.AddChangeCallback("performancemod_other_enabled", function() timer.Simple(0.1, ApplyClientSettings) end, "PerformanceMod")
cvars.AddChangeCallback("performancemod_fps_boost", function() timer.Simple(0.1, ApplyClientSettings) end, "PerformanceMod")

local function CreateSettingsMenu()
    spawnmenu.AddToolMenuOption("Utilities", "User", "Performance Mod", "Performance Mod", "", "", function(panel)
        panel:ClearControls()

        local warningLabel = panel:Help("WARNING: Toggling optimizations may cause the game to freeze for a few seconds.")
        warningLabel:SetColor(Color(255, 0, 0)) 
        local noteLabel = panel:Help("Changes are applied immediately. If issues persist, try reconnecting or restarting the game.")
        noteLabel:SetColor(Color(255, 0, 0)) 
        panel:Help("")

        panel:Help("Client-side Optimizations")
        panel:CheckBox("Enable FPS Boost", "performancemod_fps_boost")
        panel:ControlHelp("Applies performance commands to potentially increase FPS.")

        panel:CheckBox("Enable Network Optimization", "performancemod_network_enabled")
        panel:ControlHelp("Adjusts network-related settings to potentially reduce lag and improve connection stability.")

        panel:CheckBox("Enable Other Optimizations", "performancemod_other_enabled")
        panel:ControlHelp("Optimizes various game systems including sound processing and file I/O.")

        if LocalPlayer():IsAdmin() then
            panel:Help("")
            panel:Help("Server-side Optimizations (Admin Only)")
            local serverWarning = panel:Help("WARNING: These optimizations are experimental and may affect gameplay.")
            serverWarning:SetColor(Color(255, 0, 0)) 
            panel:CheckBox("Optimize Server Animations", "performancemod_server_optimize_animations")
            panel:ControlHelp("Disables certain animations on the server to reduce CPU usage.")

            panel:CheckBox("Optimize Server Memory", "performancemod_server_optimize_memory")
            panel:ControlHelp("Adjusts memory-related settings on the server for better performance.")
        end
    end)
end

hook.Add("PopulateToolMenu", "PerformanceModMenu", CreateSettingsMenu)

net.Receive("PerformanceModApplyServer", function()
    print("Server-side optimizations applied.")
end)

local function ApplyServerOptimizations()
    if LocalPlayer():IsAdmin() then
        net.Start("PerformanceModApplyServer")
        net.SendToServer()
    end
end

cvars.AddChangeCallback("performancemod_server_optimize_animations", function() timer.Simple(0.1, ApplyServerOptimizations) end, "PerformanceModServer")
cvars.AddChangeCallback("performancemod_server_optimize_memory", function() timer.Simple(0.1, ApplyServerOptimizations) end, "PerformanceModServer")local performance_commands = {
    {"gmod_mcore_test", "1"},
    {"mem_max_heapsize", "131072"},
    {"mem_max_heapsize_dedicated", "131072"},
    {"mem_min_heapsize", "131072"},
    {"threadpool_affinity", "64"},
    {"mat_queue_mode", "2"},
    {"mat_powersavingsmode", "0"},
    {"r_queued_ropes", "1"},
    {"r_threaded_renderables", "1"},
    {"r_threaded_particles", "1"},
    {"r_threaded_client_shadow_manager", "1"},
    {"cl_threaded_client_leaf_system", "1"},
    {"cl_threaded_bone_setup", "1"},
    {"ai_expression_optimization", "1"},
    {"fast_fogvolume", "1"},
    {"mat_managedtextures", "0"}
}

local network_commands = {
    {"cl_forcepreload", "1"},
    {"cl_lagcompensation", "1"},
    {"cl_timeout", "3600"},
    {"cl_smoothtime", "0.05"},
    {"cl_localnetworkbackdoor", "1"},
    {"cl_cmdrate", "66"},
    {"cl_updaterate", "66"},
    {"cl_interp_ratio", "2"},
    {"net_maxpacketdrop", "0"},
    {"net_chokeloop", "1"},
    {"net_compresspackets", "1"},
    {"net_splitpacket_maxrate", "50000"},
    {"net_compresspackets_minsize", "4097"},
    {"net_maxroutable", "1200"},
    {"net_maxfragments", "1200"},
    {"net_maxfilesize", "64"},
    {"net_maxcleartime", "0"},
    {"rate", "1048576"}
}

local other_commands = {
    {"snd_mix_async", "1"},
    {"snd_async_fullyasync", "1"},
    {"snd_async_minsize", "0"},
    {"sv_forcepreload", "1"},
    {"studio_queue_mode", "1"},
    {"filesystem_max_stdio_read", "64"},
    {"in_usekeyboardsampletime", "1"},
    {"r_radiosity", "4"},
    {"mat_frame_sync_enable", "0"},
    {"mat_framebuffercopyoverlaysize", "0"},
    {"lod_TransitionDist", "2000"},
    {"filesystem_unbuffered_io", "0"}
}

CreateClientConVar("performancemod_network_enabled", "1", true, false, "Enable network optimizations")
CreateClientConVar("performancemod_other_enabled", "1", true, false, "Enable other optimizations")
CreateClientConVar("performancemod_fps_boost", "0", true, false, "Enable FPS boost")

local function RunCommands(commands)
    for _, cmd in ipairs(commands) do
        RunConsoleCommand(unpack(cmd))
    end
end

local function ApplyClientSettings()
    if GetConVar("performancemod_fps_boost"):GetBool() then
        RunCommands(performance_commands)
    else
        RunCommands({
            {"gmod_mcore_test", "0"},
            {"mat_queue_mode", "-1"},
            {"r_queued_ropes", "0"},
            {"r_threaded_renderables", "0"},
            {"r_threaded_particles", "0"},
            {"r_threaded_client_shadow_manager", "0"},
            {"cl_threaded_client_leaf_system", "0"},
            {"cl_threaded_bone_setup", "0"},
            {"ai_expression_optimization", "0"},
            {"fast_fogvolume", "0"},
            {"mat_managedtextures", "1"}
        })
    end

    if GetConVar("performancemod_network_enabled"):GetBool() then
        RunCommands(network_commands)
    else
        RunCommands({
            {"cl_forcepreload", "0"},
            {"cl_lagcompensation", "1"},
            {"cl_timeout", "30"},
            {"cl_smoothtime", "0.1"},
            {"cl_localnetworkbackdoor", "0"},
            {"cl_cmdrate", "30"},
            {"cl_updaterate", "20"},
            {"cl_interp_ratio", "2"},
            {"net_maxpacketdrop", "5000"},
            {"net_chokeloop", "0"},
            {"net_compresspackets", "1"},
            {"net_splitpacket_maxrate", "1048576"},
            {"net_compresspackets_minsize", "1024"},
            {"net_maxroutable", "1200"},
            {"net_maxfragments", "1260"},
            {"net_maxfilesize", "16"},
            {"net_maxcleartime", "4"},
            {"rate", "196608"}
        })
    end

    if GetConVar("performancemod_other_enabled"):GetBool() then
        RunCommands(other_commands)
    else
        RunCommands({
            {"snd_mix_async", "0"},
            {"snd_async_fullyasync", "0"},
            {"snd_async_minsize", "262144"},
            {"sv_forcepreload", "0"},
            {"studio_queue_mode", "0"},
            {"filesystem_max_stdio_read", "32"},
            {"in_usekeyboardsampletime", "0"},
            {"r_radiosity", "2"},
            {"mat_frame_sync_enable", "1"},
            {"mat_framebuffercopyoverlaysize", "128"},
            {"lod_TransitionDist", "800"},
            {"filesystem_unbuffered_io", "1"}
        })
    end
end

timer.Simple(1, ApplyClientSettings)

cvars.AddChangeCallback("performancemod_network_enabled", function() timer.Simple(0.1, ApplyClientSettings) end, "PerformanceMod")
cvars.AddChangeCallback("performancemod_other_enabled", function() timer.Simple(0.1, ApplyClientSettings) end, "PerformanceMod")
cvars.AddChangeCallback("performancemod_fps_boost", function() timer.Simple(0.1, ApplyClientSettings) end, "PerformanceMod")

local function CreateSettingsMenu()
    spawnmenu.AddToolMenuOption("Utilities", "User", "Performance Mod", "Performance Mod", "", "", function(panel)
        panel:ClearControls()

        local warningLabel = panel:Help("WARNING: Toggling optimizations may cause the game to freeze for a few seconds.")
        warningLabel:SetColor(Color(255, 0, 0)) 
        local noteLabel = panel:Help("Changes are applied immediately. If issues persist, try reconnecting or restarting the game.")
        noteLabel:SetColor(Color(255, 0, 0)) 
        panel:Help("")

        panel:Help("Client-side Optimizations")
        panel:CheckBox("Enable FPS Boost", "performancemod_fps_boost")
        panel:ControlHelp("Applies performance commands to potentially increase FPS.")

        panel:CheckBox("Enable Network Optimization", "performancemod_network_enabled")
        panel:ControlHelp("Adjusts network-related settings to potentially reduce lag and improve connection stability.")

        panel:CheckBox("Enable Other Optimizations", "performancemod_other_enabled")
        panel:ControlHelp("Optimizes various game systems including sound processing and file I/O.")

        if LocalPlayer():IsAdmin() then
            panel:Help("")
            panel:Help("Server-side Optimizations (Admin Only)")
            local serverWarning = panel:Help("WARNING: These optimizations are experimental and may affect gameplay.")
            serverWarning:SetColor(Color(255, 0, 0)) 
            panel:CheckBox("Optimize Server Animations", "performancemod_server_optimize_animations")
            panel:ControlHelp("Disables certain animations on the server to reduce CPU usage.")

            panel:CheckBox("Optimize Server Memory", "performancemod_server_optimize_memory")
            panel:ControlHelp("Adjusts memory-related settings on the server for better performance.")
        end
    end)
end

hook.Add("PopulateToolMenu", "PerformanceModMenu", CreateSettingsMenu)

net.Receive("PerformanceModApplyServer", function()
    print("Server-side optimizations applied.")
end)

local function ApplyServerOptimizations()
    if LocalPlayer():IsAdmin() then
        net.Start("PerformanceModApplyServer")
        net.SendToServer()
    end
end

cvars.AddChangeCallback("performancemod_server_optimize_animations", function() timer.Simple(0.1, ApplyServerOptimizations) end, "PerformanceModServer")
cvars.AddChangeCallback("performancemod_server_optimize_memory", function() timer.Simple(0.1, ApplyServerOptimizations) end, "PerformanceModServer")