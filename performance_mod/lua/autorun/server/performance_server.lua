
if SERVER then
    if timer.Exists("CheckHookTimes") then
    timer.Remove("CheckHookTimes")
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove( "Think", "CheckSchedules")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    timer.Destroy("HostnameThink")
	hook.Add("MouthMoveAnimation", "Optimization", function() return nil end)
	hook.Add("GrabEarAnimation", "Optimization", function() return nil end)
    end
end
    for k, v in pairs(ents.FindByClass("env_fire")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("trigger_hurt")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("prop_physics")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("prop_ragdoll")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("light")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("spotlight_end")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("beam")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("point_spotlight")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("env_sprite")) do v:Remove() end
	for k,v in pairs(ents.FindByClass("func_tracktrain")) do v:Remove() end
	for k,v in pairs(ents.FindByClass("light_spot")) do v:Remove() end
	for k,v in pairs(ents.FindByClass("point_template")) do v:Remove()  
	RunConsoleCommand("mem_max_heapsize", "131072")
	RunConsoleCommand("mem_max_heapsize_dedicated", "131072")
	RunConsoleCommand("mem_min_heapsize", "131072")
	RunConsoleCommand("threadpool_affinity", "64")
	RunConsoleCommand("decalfrequency", "10")
	RunConsoleCommand("gmod_physiterations", "2")
	RunConsoleCommand("sv_minrate", "1048576")
end