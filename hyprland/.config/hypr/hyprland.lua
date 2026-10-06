local mainMod         = "SUPER"
local terminal        = "foot"
local menu            = "rofi -show combi"
local workspace_layer = 0


-- exec_cmd in cwd of the currently active window
local function exec_cmd_cwd(command)
    local w = hl.get_active_window()
    local pid = w and w.pid
    local cwd

    if pid then
        local f = io.open("/proc/" .. pid .. "/task/" .. pid .. "/children")
        local children = f and f:read("*a")
        if f then f:close() end

        for child in (children or ""):gmatch("%d+") do
            local p = io.popen("readlink -e /proc/" .. child .. "/cwd 2>/dev/null")
            cwd = p and p:read("*l")
            if p then p:close() end
            if cwd then break end
        end

        if not cwd then
            local p = io.popen("readlink -e /proc/" .. pid .. "/cwd 2>/dev/null")
            cwd = p and p:read("*l")
            if p then p:close() end
        end
    end

    hl.dispatch(hl.dsp.exec_cmd(
        "cd ".. cwd .. ";" .. command
    ))
end

local function set_workspace_layout(layout)
    local workspace = hl.get_active_workspace()

    if not workspace then
        return
    end

    hl.workspace_rule({ workspace = tostring(workspace.id), layout = layout })

    hl.dispatch(hl.dsp.exec_cmd(
        string.format("notify-send 'Set workspace layout to %s'", layout)
    ))
end

local function bind_workspace_layer(key, layer)
    hl.bind(mainMod .. " + " .. key, function()
        workspace_layer = layer
        hl.dispatch(hl.dsp.exec_cmd(
            string.format("notify-send 'Set workspace layer to %s'", layer // 10)
        ))
    end)
end


hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})


hl.on("hyprland.start", function () 
  hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("gnome-keyring-daemon --start")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("mako")
  hl.exec_cmd("playerctld daemon")
  hl.exec_cmd("while true; do waybar; done")
end)


hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 2,

        border_size = 2,

        col = {
            active_border   = "rgba(9f9f9fff)",
            inactive_border = "rgba(181818ff)",
        },

        resize_on_border = true,

        allow_tearing = true,

        layout = "dwindle",
    },

    render = {
        direct_scanout = 1, -- For any fullscreen window
    },

    quirks = {
        -- Workaround for direct_scanout black screen
        -- https://github.com/hyprwm/Hyprland/discussions/14843
        skip_non_kms_dmabuf_formats = 1,
    },

    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },

    cursor = {
        inactive_timeout = 8,
        no_warps = true
    },

    decoration = {
        rounding       = 6,
        rounding_power = 3,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = false
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 0.4,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 0.6,  bezier = "quick" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 0.6,  bezier = "quick" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 0.6,  bezier = "linear" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 0.7,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 0.7,  bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 0.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 0.8,  bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 1,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 0.5,  bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 0.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 0.5,  bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 0.8,  bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 0.8,  bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 0.8,  bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 5,    bezier = "quick" })

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper  = 1,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        enable_anr_dialog        = false,
    },
})


hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:win_space_toggle",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.4,
            middle_button_emulation = false,
            disable_while_typing = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})


hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", function()
    exec_cmd_cwd(terminal)
end)
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
local closeWindowBind = hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + SHIFT + Delete", hl.dsp.exec_cmd("loginctl terminate-session $XDG_SESSION_ID"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.layout("colresize 1.0"))
hl.bind(mainMod .. " + R", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.pin())

hl.bind(mainMod .. " + SHIFT + T", function()
    set_workspace_layout("scrolling")
end)

hl.bind(mainMod .. " + T", function()
    set_workspace_layout("dwindle")
end)

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --freeze --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window --freeze --clipboard-only"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

hl.bind(mainMod .. " + Y", hl.dsp.window.resize({ x = -150, y = 0, relative=true }))
hl.bind(mainMod .. " + U", hl.dsp.window.resize({ x = 0, y = 150, relative=true }))
hl.bind(mainMod .. " + I", hl.dsp.window.resize({ x = 0, y = -150, relative=true }))
hl.bind(mainMod .. " + O", hl.dsp.window.resize({ x = 150, y = 0, relative=true }))

hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.window.resize({ x = -35, y = 0, relative=true }))
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.resize({ x = 0, y = 35, relative=true }))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.window.resize({ x = 0, y = -35, relative=true }))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.window.resize({ x = 35, y = 0, relative=true }))

-- Switch workspaces
for i = 1, 10 do
    local key = i % 10

    hl.bind(mainMod .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({
            workspace = workspace_layer + i
        }))
    end)

    hl.bind(mainMod .. " + SHIFT + " .. key, function()
        hl.dispatch(hl.dsp.window.move({
            workspace = workspace_layer + i
        }))
    end)
end

-- Switch workspace layers
-- Grave (~) resets the layer
bind_workspace_layer("Grave", 0)
-- F1 .. F12
for i = 1, 12 do
    bind_workspace_layer("F" .. i, i * 10)
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- "Smart gaps" / "No gaps when only"
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})

hl.window_rule({
    name  = "center-xdg-popups",
    match = {
        float = true,
        class = "^(xdg-desktop-portal.*)$",
    },

    center = true,
    size = { 1000, 800 },
})

hl.window_rule({
    name  = "pin-firefox-popup-player",
    match = {
        class = "firefox",
        title = "Picture-in-Picture"
    },

    float = true,
    pin = true,
    no_focus = false,
    size = { 800, 450 },
})

hl.window_rule({
    name  = "allow-fullscreen-tearing",
    match = {
        fullscreen = true,
    },

    immediate = true
})
