-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})

hl.layer_rule({
    match = { namespace = "vicinae" },
    blur = true,
    ignore_alpha = 0,
})


hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = { top = 3, right = 10, bottom = 10, left = 10 },

        border_size = 1,

        col = {
            active_border   = { colors = {"#3602C2", "#230085"}, angle = 45 },
            inactive_border = "#000000",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    dwindle = {
        --smart_split = true,
        --precise_mouse_move = true,
    },

    decoration = {
        rounding       = 15,
        rounding_power = 3,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.90,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = false,
            size      = 4,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})