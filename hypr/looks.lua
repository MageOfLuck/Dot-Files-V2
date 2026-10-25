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
        gaps_out = { top = 6, right = 6, bottom = 6, left = 6 },

        border_size = 3,

        col = {
            active_border   = { colors = {"#ffffff", "#ffffff"}, angle = 45 },
            inactive_border = "#000000",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = true,

        layout = "dwindle",
    },

    dwindle = {
        preserve_split = true,
        --precise_mouse_move = true,
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.83,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Hyprglass configuration
    if hl.plugin.hyprglass then
        local hg = hl.plugin.hyprglass

        hg.config({
            enabled = true,

            default_theme = "dark",
            --default_preset = "pomme",

            -- Color corrections
            dark = {
                brightness   = 1.0,
                contrast     = 1.4,
                saturation   = 1.40,
                vibrancy     = 1.0,
                adaptive_dim = 0.05,
            },

            -- Liquid Glass effects
            refraction_strength = 0.45,
            chromatic_aberration = 0.6,
            lens_distortion      = 0.8,
            edge_thickness       = 0.05,
        })
    end