FpsCapConfig = {}

FpsCapConfig.MaxFps       = 60    -- allowed frame rate
FpsCapConfig.Tolerance    = 3     -- grace above the cap before it counts (63 = violation)
FpsCapConfig.GraceSeconds = 5     -- sustained seconds above the limit before enforcement
FpsCapConfig.ReleaseSeconds = 3   -- sustained seconds back under the limit to release

-- true  = freeze the player + fullscreen warning until they cap their FPS
-- false = warning banner only (no gameplay block)
FpsCapConfig.Enforce      = true

-- Reminder shown once after spawn
FpsCapConfig.JoinReminder = true
