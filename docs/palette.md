# Gruvbox Material Dark Hard palette

Every config in this repo uses these values. If you change one, grep the repo
for the old hex value and change it everywhere.

Source: [sainnhe/gruvbox-material](https://github.com/sainnhe/gruvbox-material),
`background = hard`, `foreground = material`.

## Base colors

| Name               | Hex       | Used for                                            |
|--------------------|-----------|-----------------------------------------------------|
| bg_dim             | `#141617` | i3 unfocused windows, polybar background            |
| bg0                | `#1d2021` | Terminal / editor / rofi / dunst background         |
| bg1                | `#282828` | Slightly raised surfaces (input bars, tmux status)  |
| bg3                | `#3c3836` | ANSI black (color0), selections in fzf              |
| bg5                | `#504945` | Borders, separators, inactive frames                |
| bg_visual_yellow   | `#473c29` | "Focused" accent background (i3, polybar, rofi)     |
| fg0                | `#d4be98` | Normal text                                         |
| fg1                | `#ddc7a1` | Emphasized text, ANSI bright white                  |
| grey0              | `#7c6f64` | Very dim text (fish autosuggestions)                |
| grey1              | `#928374` | Comments, dim text, ANSI bright black (color8)      |
| grey2              | `#a89984` | Secondary text                                      |

## Accent colors

| Name   | Hex       | ANSI      |
|--------|-----------|-----------|
| red    | `#ea6962` | 1 / 9     |
| green  | `#a9b665` | 2 / 10    |
| yellow | `#d8a657` | 3 / 11    |
| blue   | `#7daea3` | 4 / 12    |
| purple | `#d3869b` | 5 / 13    |
| aqua   | `#89b482` | 6 / 14    |
| orange | `#e78a4e` | (none)    |

## Terminal ANSI table

Gruvbox Material uses the same value for normal and bright colors. Only black
and white differ.

```
color0  #3c3836   color8  #928374
color1  #ea6962   color9  #ea6962
color2  #a9b665   color10 #a9b665
color3  #d8a657   color11 #d8a657
color4  #7daea3   color12 #7daea3
color5  #d3869b   color13 #d3869b
color6  #89b482   color14 #89b482
color7  #d4be98   color15 #ddc7a1
```

## Conventions

* **Focused / active** = `#473c29` background with `#d8a657` (yellow) accents.
* **Urgent / error** = `#ea6962` (red) background with `#1d2021` text.
* **Borders** = `#504945`.
* Font everywhere: **JetBrainsMono Nerd Font**, size 10 (rofi 11).

## Where colors live

| Program   | File                                              |
|-----------|---------------------------------------------------|
| i3        | `.config/i3/config`                               |
| polybar   | `.config/polybar/config.ini` (`[colors]`)         |
| kitty     | `.config/kitty/kitty.conf`                        |
| terminator| `.config/terminator/config` (legacy)              |
| X apps    | `.Xresources`                                     |
| rofi      | `.config/rofi/themes/gruvbox-material-dark.rasi`  |
| dunst     | `.config/dunst/dunstrc`                           |
| tmux      | `.tmux.conf`                                      |
| fish      | `.config/fish/conf.d/gruvbox-material.fish`       |
| fzf       | `.config/fish/config.fish` (`FZF_DEFAULT_OPTS`)   |
| starship  | `.config/starship.toml` (`[palettes]`)            |
| lockscreen| `.config/i3/scripts/lock.sh`                      |
| neovim    | plugin `sainnhe/gruvbox-material`                 |
| btop      | built-in `gruvbox_material_dark` theme            |
