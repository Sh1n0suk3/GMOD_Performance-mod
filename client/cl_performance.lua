local PerformanceMod = PerformanceMod or {}
PerformanceMod.Config = PerformanceMod.Config or {}

PerformanceMod.Config.ApplyDelay = 2
PerformanceMod.Config.CommandInterval = 0.5

local performance_commands = {
    {"gmod_mcore_test", "1"},
    {"threadpool_affinity", "1"},
    {"mat_queue_mode", "2"},
    {"mat_powersavingsmode", "0"},
    {"r_queued_ropes", "1"},
    {"r_threaded_renderables", "1"},
    {"r_threaded_particles", "1"},
    {"r_threaded_client_shadow_manager", "1"},
    {"cl_threaded_bone_setup", "1"},
    {"ai_expression_optimization", "1"},
    {"fast_fogvolume", "1"}
}

local network_commands = {
    {"cl_lagcompensation", "1"},
    {"cl_smoothtime", "0.05"},
    {"cl_localnetworkbackdoor", "1"},
    {"cl_cmdrate", "66"},
    {"cl_updaterate", "66"},
    {"cl_interp_ratio", "2"},
    {"net_maxpacketdrop", "0"},
    {"net_chokeloop", "1"},
    {"net_compresspackets", "1"},
    {"net_compresspackets_minsize", "4097"},
    {"net_maxfilesize", "64"},
    {"rate", "786432"},
    {"net_usesocketsforloopback", "1"},
    {"net_queued_packet_thread", "1"},
    {"net_udp_rcvbuf", "131072"},
    {"net_splitrate", "1"}
}

local other_commands = {
    {"snd_mix_async", "1"},
    {"snd_async_fullyasync", "1"},
    {"sv_forcepreload", "1"},
    {"studio_queue_mode", "1"},
    {"filesystem_max_stdio_read", "64"},
    {"in_usekeyboardsampletime", "1"},
    {"mat_frame_sync_enable", "0"},
    {"mat_framebuffercopyoverlaysize", "0"},
    {"particle_sim_alt_cores", "2"},
    {"opt_EnumerateLeavesFastAlgorithm", "1"},
    {"snd_lockpartial", "1"},
    {"voice_steal", "2"},
    {"cl_predictweapons", "1"},
    {"cl_pred_optimize", "2"},
    {"filesystem_use_overlapped_io", "1"}
}

CreateClientConVar("performancemod_messages_enabled", "1", true, true, "Enable/disable chat messages")
CreateClientConVar("performancemod_network_enabled", "1", true, false, "Enable network optimizations")
CreateClientConVar("performancemod_other_enabled", "1", true, false, "Enable other optimizations")
CreateClientConVar("performancemod_fps_boost", "1", true, false, "Enable FPS boost")

local function RunCommands(commands)
    local currentCommand = 1
    local function ApplyNextCommand()
        if currentCommand <= #commands then
            RunConsoleCommand(unpack(commands[currentCommand]))
            currentCommand = currentCommand + 1
            timer.Simple(PerformanceMod.Config.CommandInterval, ApplyNextCommand)
        end
    end
    timer.Simple(PerformanceMod.Config.CommandInterval, ApplyNextCommand)
end

local function ApplyClientSettings()
    if GetConVar("performancemod_fps_boost"):GetBool() then
        RunCommands(performance_commands)
    else
        RunCommands({
            {"gmod_mcore_test", "0"},
            {"threadpool_affinity", "0"},
            {"mat_queue_mode", "-1"},
            {"r_queued_ropes", "0"},
            {"r_threaded_renderables", "0"},
            {"r_threaded_particles", "0"},
            {"r_threaded_client_shadow_manager", "0"},
            {"cl_threaded_bone_setup", "0"},
            {"ai_expression_optimization", "0"},
            {"fast_fogvolume", "0"}
        })
    end

    if GetConVar("performancemod_network_enabled"):GetBool() then
        RunCommands(network_commands)
    else
        RunCommands({
            {"cl_lagcompensation", "1"},
            {"cl_smoothtime", "0.1"},
            {"cl_localnetworkbackdoor", "0"},
            {"cl_cmdrate", "30"},
            {"cl_updaterate", "20"},
            {"cl_interp_ratio", "2"},
            {"net_maxpacketdrop", "5000"},
            {"net_chokeloop", "0"},
            {"net_compresspackets", "1"},
            {"net_compresspackets_minsize", "1024"},
            {"net_maxfilesize", "16"},
            {"rate", "100000"},
            {"net_usesocketsforloopback", "0"},
            {"net_queued_packet_thread", "0"},
            {"net_udp_rcvbuf", "131072"},
            {"net_splitrate", "0"}
        })
    end

    if GetConVar("performancemod_other_enabled"):GetBool() then
        RunCommands(other_commands)
    else
        RunCommands({
            {"snd_mix_async", "0"},
            {"snd_async_fullyasync", "0"},
            {"sv_forcepreload", "0"},
            {"studio_queue_mode", "0"},
            {"filesystem_max_stdio_read", "32"},
            {"in_usekeyboardsampletime", "0"},
            {"mat_frame_sync_enable", "1"},
            {"mat_framebuffercopyoverlaysize", "128"},
            {"particle_sim_alt_cores", "2"},
            {"opt_EnumerateLeavesFastAlgorithm", "1"},
            {"snd_lockpartial", "0"},
            {"voice_steal", "0"},
            {"cl_predictweapons", "0"},
            {"cl_pred_optimize", "0"},
            {"filesystem_use_overlapped_io", "1"}
        })
    end

    if GetConVar("performancemod_messages_enabled"):GetBool() then
        timer.Simple(5, function()
            if GetConVar("performancemod_fps_boost"):GetBool() then
                chat.AddText(Color(0, 255, 0), "[PerformanceMod] Optimizations applied.")
            else
                chat.AddText(Color(0, 255, 0), "[PerformanceMod] Optimizations reverted.")
            end
        end)
    end
end

timer.Simple(PerformanceMod.Config.ApplyDelay, ApplyClientSettings)

cvars.AddChangeCallback("performancemod_network_enabled", function()
    timer.Simple(0.1, ApplyClientSettings)
end, "PerformanceMod")

cvars.AddChangeCallback("performancemod_other_enabled", function()
    timer.Simple(0.1, ApplyClientSettings)
end, "PerformanceMod")

cvars.AddChangeCallback("performancemod_fps_boost", function()
    timer.Simple(0.1, ApplyClientSettings)
end, "PerformanceMod")

local function CreateSettingsMenu()
    spawnmenu.AddToolMenuOption("Utilities", "User", "Performance Mod", "Performance Mod", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Messaging Options")
        panel:CheckBox("Enable Messages", "performancemod_messages_enabled")
        panel:ControlHelp("Show optimization status messages in chat.")
        panel:Help("Client-side Optimizations")
        panel:CheckBox("Enable FPS Boost", "performancemod_fps_boost")
        panel:ControlHelp("Applies performance commands to potentially increase FPS.")
        panel:CheckBox("Enable Network Optimization", "performancemod_network_enabled")
        panel:ControlHelp("Adjusts network-related settings to potentially reduce lag and improve connection stability.")
        panel:CheckBox("Enable Other Optimizations", "performancemod_other_enabled")
        panel:ControlHelp("Optimizes various game systems including sound processing and file I/O.")
    end)
end

hook.Add("PopulateToolMenu", "PerformanceModMenu", CreateSettingsMenu)
