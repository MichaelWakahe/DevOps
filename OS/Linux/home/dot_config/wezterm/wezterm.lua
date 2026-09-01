local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- FORCE DIRECT3D BACKEND ON WINDOWS
-- Bypasses legacy OpenGL implementations to prevent glium window creation errors
config.prefer_egl = true

-- AUTOMATIC RENDERING FALLBACK
-- Check if any hardware graphics cards are available. If not, use CPU software rendering.
local has_gpu = false
for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
    if gpu.device_type == 'IntegratedGpu' or gpu.device_type == 'DiscreteGpu' then
        has_gpu = true
        break
    end
end

if not has_gpu then
    config.front_end = "Software"
end

-- GLOBAL SETTINGS
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font('JetBrains Mono')

-- OPACITY AND TRANSPARENCY SETTINGS
config.window_background_opacity = 0.85

-- PLATFORM-SPECIFIC SETTINGS
if wezterm.target_triple:find("windows") then
    -- Windows specific settings
    config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '--login', '-i' }

    -- Frosted glass effect for Windows 11 (Options: 'Mica', 'Acrylic', or 'Tabbed')
    config.win32_system_backdrop = 'Acrylic'

elseif wezterm.target_triple:find("apple") then
    -- macOS specific settings
    config.font_size = 15.0

    -- Frosted glass effect for Mac (higher numbers mean more blur)
    config.macos_window_background_blur = 20

else
    -- Linux specific settings
    config.font_size = 11.0

    -- Optional blur for Linux desktop environments running Wayland
    config.wayland_window_background_blur = true
end

-- CUSTOM KEYBINDINGS
config.keys = {
  -- Split horizontally (Top/Bottom stacked rows)
  {
    key = 'H',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Split vertically (Left/Right side-by-side columns)
  {
    key = 'V',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- PowerShell-style Paste with SHIFT + V
  {
    key = 'V',
    mods = 'SHIFT',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

-- CUSTOM MOUSE BINDINGS
config.mouse_bindings = {
  -- Right-click to paste text from the system clipboard
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

return config
