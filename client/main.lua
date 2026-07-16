-- client/main.lua
-- 60 FPS fairness cap. GTA physics favour high frame rates (drag, kerbs,
-- acceleration), so racing above the cap is an unfair advantage. A script
-- cannot force-limit the render FPS — it detects and blocks instead.

local fpsSamples  = {}
local sampleIdx   = 0
local frameCount  = 0
local avgFps      = 60.0

local overSince   = nil   -- GetGameTimer() when the player first went over
local underSince  = nil
local blocked     = false

-- ── FPS measurement (frame counter, 1 s samples, 5 s rolling average) ────────

CreateThread(function()
    while true do
        frameCount = frameCount + 1
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        sampleIdx = (sampleIdx % 5) + 1
        fpsSamples[sampleIdx] = frameCount
        frameCount = 0

        local sum, n = 0, 0
        for _, s in ipairs(fpsSamples) do
            sum = sum + s
            n = n + 1
        end
        if n > 0 then avgFps = sum / n end
    end
end)

-- ── Enforcement state machine ────────────────────────────────────────────────

CreateThread(function()
    while true do
        Wait(1000)

        local limit = FpsCapConfig.MaxFps + FpsCapConfig.Tolerance
        local now   = GetGameTimer()

        if avgFps > limit then
            underSince = nil
            overSince  = overSince or now

            if not blocked
            and (now - overSince) >= FpsCapConfig.GraceSeconds * 1000 then
                blocked = true
                if FpsCapConfig.Enforce then
                    local ped = PlayerPedId()
                    local veh = GetVehiclePedIsIn(ped, false)
                    FreezeEntityPosition(ped, true)
                    if veh ~= 0 then FreezeEntityPosition(veh, true) end
                end
            end
        else
            overSince  = nil
            underSince = underSince or now

            if blocked
            and (now - underSince) >= FpsCapConfig.ReleaseSeconds * 1000 then
                blocked = false
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                FreezeEntityPosition(ped, false)
                if veh ~= 0 then FreezeEntityPosition(veh, false) end
                TriggerEvent("chat:addMessage", { args = { "^2[fps]", "Thanks — FPS back under the cap. You're free to go." } })
            end
        end
    end
end)

-- ── Warning overlay ──────────────────────────────────────────────────────────

local function drawTxt(text, x, y, scale, r, g, b, a)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(true)
    SetTextDropShadow()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

CreateThread(function()
    while true do
        if blocked then
            if FpsCapConfig.Enforce then
                DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 190)
            end
            drawTxt("FPS LIMIT EXCEEDED", 0.5, 0.36, 1.0, 255, 60, 60, 255)
            drawTxt(("This server enforces a %d FPS cap for fair racing — you are averaging %d FPS."):format(
                FpsCapConfig.MaxFps, math.floor(avgFps)), 0.5, 0.46, 0.45, 255, 255, 255, 235)
            drawTxt("Cap your FPS: enable VSync (Settings → Graphics), or set a 60 FPS limit", 0.5, 0.52, 0.4, 210, 210, 210, 225)
            drawTxt("in NVIDIA/AMD control panel or RivaTuner. You'll be released automatically.", 0.5, 0.55, 0.4, 210, 210, 210, 225)
            drawTxt(("current avg: %d FPS"):format(math.floor(avgFps)), 0.5, 0.63, 0.55,
                avgFps > FpsCapConfig.MaxFps + FpsCapConfig.Tolerance and 255 or 80,
                avgFps > FpsCapConfig.MaxFps + FpsCapConfig.Tolerance and 60 or 220,
                avgFps > FpsCapConfig.MaxFps + FpsCapConfig.Tolerance and 60 or 120, 255)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- ── Join reminder ─────────────────────────────────────────────────────────────

if FpsCapConfig.JoinReminder then
    CreateThread(function()
        Wait(15000)   -- after loading/spawn settles
        TriggerEvent("chat:addMessage", { args = { "^3[fps]",
            ("This server enforces a %d FPS cap for fair racing — cap yours via VSync or a frame limiter."):format(FpsCapConfig.MaxFps) } })
    end)
end
