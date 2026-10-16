CLAUDE.md

We are now on a Linux machine, so we can remove any artifacts
from our time on windows. No need to think about windows again.

NOTES.md

I am currently _mostly_ on a Ubuntu 24.04 without internet, via thinlinc. I have
previously been on a Ubuntu 24.04 laptop. I have also used Ubuntu
24.04 desktops with internet. I want to support all versions. Some of the dotfiles
have internet access turned off, which isnt portable between the systems.

We are now in a good linux environment, so we have more latitude.

copy_to_home.py

We can remove the "Scripts (files starting with "#!") are made executable, since the..."
workaround / fixup, we will never be on windows again.

copy_to_repo.py

We should make the imported _DOTFILES and _HOME public (no underscore), since
they now are intended to be shared

SETUP.MD

Remove the "On the work machine this goes..." note

Note that the offline bundle is for installing on a machine without internet

Remove all references to the JetBrains Toolbox from all files, I need to
thing about how I want to handle that setup

What is " -o Dir::Cache::archives="$PWD"" for?

Lets drop the concept of "Work machine". If a step is specific
for a machine without internet, it should say that instead.

Remove the instruction on how to add certificates to chrome with a
general note that certificates can be added separately to the browser.

Should UV and Pixi really be so early in the setup sequence?

Should rust be ordered together with uv and pixi setups? My
understanding is that the setup mechanics are similar.

Remove the Azure CLI and fstab sections.

In the "Terminal tools" list, check the ordering. The explainations matches
the installation order, except for "expect" which is explained last

We can move some of the build things from the i3lock-color section to the "Building C/C++" section,
standard tools like autoconf, gcc and make.

In the Notes section, remove teh bullet about no longer installed

Do I still need to use a separate PPA for git? I added it a long time ago when
the ubuntu repo version was very old.

6. The offline bundle seems to assume that I always install offline, which
might not be true. Does it need a separate set of instructions for installing
on a system with internet? On those a lot of plugin updates would be much simpler.
This also applies to the fonts.

8. Does fish really need a separate section? It could be installed by one of the
other apt commands. I dont think we need the chsh admonition, fish is already
the default in kitty.

Here starship gets online instructions. Figure out how to organize the other
online instructions I asked for previously.

Remove the note on what zoxide does.

Kitty also gets a section, but it doesn seem to add any information. Should it also have
a online, non-apt instruction?

I dont understand the note about how "ssh expands to kitten ssh".

We dont need to lock down that picom is "only so GTK transparency isnt drawn black". Remove
the "only" part

unclutter-xfixes should be on all machines, I think. I want to hide the cursor on
all of them.

Can we drop the "surf5r" repo reference if the i3 version is new enough?

For machine profiles, I want to remove the VPN display. Hopefully I remember that when
thjis review gets to the polybar config file.

Remove the nautilus section, I dont think that is a problem any more.

unclutter is not laptop-only

Remove the "These show up in apt-mark showmanual" paragrape, the ldd check and the "To build later)

Neovim needs only install too, not just the offline bundle.

Lets remove all support and config files for normal vim, I am going neovim all the way.

Section 10 is back to uv and pixi. Was the previous section long ago just about setting
up their repo files, if needed? Drop the conda bullet

REmov ethe │**Switching an existing Chrome section

Remove the pycharm paragraph

See if rustup should live with the other curl+bash install flows. Rust also
seems to be the oppossite problem from before, it lacks an offline path.

Review the docker instructions to see if they are correct and current.

Fiji and p4merge might warrent support from the offline bundle script

keybindings.md

Add how to jump between tabs in rofi

Remove namespace renaming. I will get back to this once I get to the polybar.

palette.md

Review that the color codes are correct, based on the theme

.bashrc

How is this file now different from the ubuntu standard?

Is path extensions correct? (pixi, cargo) Will running pixi/starship/rust installers
detect the existing path extensions and not add more? Is the file logically ordered

dustrc

This is a massive diff. The original file was some default/example provided by dunst.
What has it been changed to? Is it a good idea to drop the extensive example file?

gruvbox-material.fish

Is it a good idea to put these color explicitly in fish? My understanding is that
the terminal already carries the gruvbox theme colors, and that fish by default accesses
them by name eg "blue" rather than relying on static color values. It could make it
easier to change color theme, and let fish decide what colors should be used for what.

rustup.fish

Will the rust setup recognize that this file already exists, or does it have an
expectation on the content too?

config.fish

Is the hybrid key bindings new?

Similar question as for fish, is it good that we are setting the colors for FZF and
bat explicitly, rather than relying on the terminal colors?

Is the file ordered sensible?

WIll pixi pick up that the path is already added and not add it again?

What decides what goes into the "interactive block"?

i3/config

Have we changed the width of borders, compared to what I had set orgininally?

In the window rules, can we have matplotlib plots start floating?

mod+u migh conflict with getting a expression evaluation window in pycharm, I cant remember

Remove the renaming workspace keybinding

We can remove the i3status support that is commented out.

autostart.sh

We dont need to say what is in a different config file, as "No effects, see picom.conf" does

rename-workspace.sh

Remove this file. I dont want to be able to name workspaces manually, I want them
to get a name based on their content (in addition to their numerical name). I saw
there is a rust program for setting i3 workspace names, check if that is an option.

kitty.conf

Remove the settings under "│# Ctrl+click opens links (plain click only selects, like terminator)"
I will start by testing kittys default handlig of links

"no internet" section that wont be portable

lazy.lua

Check that this works both with an offline install and an online install

All the nvim lua files

I looked through them, but it is all new stuff for me. Anything I should know about?
Behaviours, features, workflows, etc

polybar.config

Showing the active window name in the center of the bar is not useful for me,
since I can see the i3 window names at the top of the screen. Remove it

Remove the VPN section

config.rasi

display-combi and display-drun _looks_ very similar, do I need both?

Not sure I will use the keybindings tab

What to you think of switching tabs with ctrl+h/l, since it already has vim-like navigation?

gruvbox-material-dark.rasi

Do you know where the settings in thilse file comes from? I cant remember if the original
was official from somewhere or my own bashed togheter.

starship.toml

Sort the pixi symbol alphabetcially?

Again, does it need a color palett or should it inhereit it from the terminal?

terminator/config

Lets drop all terminator support

.gitconfig

Same here, do we need explicit colors or should we inherit them from the terminal?

I think I prefere the 3-way grapical merge in p4merge over trying nvim

.profile

Remove the jetbrains toolbox

.tmux.conf

It was a long time ago since I used tmux, tell my how the settings have changed.

.vimrc

Remove
