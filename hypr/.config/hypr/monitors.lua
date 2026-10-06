------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "DP-2",
    mode     = "2560x1440@179.98",
    position = "0x0",
    scale    = "1",
    vrr      =  1,
    bitdepth = 10,
})
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "-1920x180",
    scale    = "1",
})
hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@60",
    position = "2560x180",
    scale    = "1",
})