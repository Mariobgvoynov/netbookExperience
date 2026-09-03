This document will go in length over my personal setup of my "Dell Inspiron mini 1018" 
netbook. It goes over the difficulties, tools used, hurdles and chosen software sweep.
So, let us begin.

Hardware:
Laptop name: Dell Inspiron 1018, "Mini"
CPU: Intel Atom N455 processor, single core, 2 threads, 1.67GHz, not overclocked as of
me writing this
GPU: Intel GMA 3150, using shared system RAM
Ram: 1GB original stick
Storage: 250GB HDD
*Note: The battery was replaced via an E-mag reseller, 4400 mAh, lasts 4h on perfor-
mance settings.

Software:
OS: Debian 13.6 Trixie, minimal server installation on E-Thernet
DE: i3-wm, started via "startx" post TTY login inquery.
Terminal: Urxvt, needed manual setup of ~/.Xresources, had to disable iso14755 mode
and setup the clipboard using, as follows:
------------------------------------------------------------------------------------
URxvt.iso14755: false
URxvt.iso14755_52: false

URxvt.keysym.C-S-0x43: eval:selection_to_clipboard
URxvt.keysym.C-S-0x56: eval:paste_clipboard
------------------------------------------------------------------------------------
*Note: The newest version of this terminal launches in the middle of the screen, to 
fix that, only viable fix I found, was adding 'clear' to the ~/.bashrc file. Under 
load, sometimes it will skip loading the .bashrc and still start amids the screen,
running 'clear' manually fixes it.
Browser: links2, alias is 'browse=links2 -g duckduckgo.com'
Other software and aliases used on daily basis include, but are not limitted to:
Monitoring: btop, htop, intel-gpu-utils(intel_gpu_top to be exact)
File editing: sc-im, presenterm(through pipx, uses MarkDown files), pixelart_tui
(through pipx)
Video streaming: ani-cli, ytbrowse, onda(Wifi radio)
*Note on ytbrowse: that is my own script, a wrapper of yt-dlp, which limits streams
to AVC1(H264), 30fps and customizable size, by default 720, on weaker systems I also
use 360p. Available tags are -f(for the resolution) and -m(for music). Should be 
attached alongside this file, use freely, of course^-^
Social: concord, with the alias concordUpdate aswell to make daily usage easier
'concordUpdate="curl --proto '=https' --tlsv1.2 -LsSf \
https://github.com/chojs23/concord/releases/latest/download/concord-installer.sh | sh"'
Games-wise: steamcmd, Wine 4.0.4(Compiled in a debian 11 container on a stronger
system and transfered, Wine performance is weak and in my personal experience I
strongly discourage using it), NES game emulation via fceux and Nestopia
Game packages used(just to save some browsing on the reader's side):
chess-tui, vitetris, chocolate-doom etc
Package managers: pipx, cargo, apt(of course)
GitHub browsing: gh, workflow is as follows:
------------------------------------------------------------------------------------
gh search repos <keyword>
gh repo view <spotted repo>
git clone <repo url>
------------------------------------------------------------------------------------ 
Games tried for Wine: Fnaf 1, TheSims1, Re-Volt(original 1999), gta 3, gta Vice City,
SimCity 3000(original), Undertale
Games, played natively: ClassiCube('/client rendertype fast' helps alot), OpenTTD, 
FreeCiv, trigger-rally, MultiMC(for minecraft, use OpenJDK 8.1, set a fixed RAM buffer, 
use legacy java tags, use OptiFine, or OptiMine for older releases, I also chased down
FastRender for a1.2.6)

-------------ACTUAL FACED DIFFICULTIES-GPU, MPV-------------------------------------
All thus far has been trivial software, here are the actual hard parts to achieve/
figure out. Mesa 25 no longer supports GMA 3150, or PineView GPU's in general. I used
Mesa Amber and compiled my own i915 drivers, the original ones, not the gallium ones,
both i915 and i915:i386. These are OpenGL 1.4 drivers only, they are not the
i915_dri... smth smth that is used to accellerate video playback, those I FAILED to
find. Trying to export the driver directories, them being as follows:
/opt/mesa-amber/lib/*
before launching the X-Server will end with error messages, I am new to Linux, I don't
know why. For that reason I made myself this system. I have properGPUbackend, it 
begins as follows:
-----------------------------------------------------------------------------------
#!/bin/bash
export LIBGL_DRIVERS_PATH=/opt/mesa-amber/lib/x86_64-linux-gnu/dri:/opt/\
mesa-amber/lib/i386-linux-gnu/dri
export LD_LIBRARY_PATH=/opt/mesa-amber/lib/x86_64-linux-gnu:/opt/mesa-amber/lib/\
i386-linux-gnu:/opt/mesa-amber/lib:$LD_LIBRARY_PATH
-----------------------------------------------------------------------------------
And in my .bashrc I have the properGPU function, which sources properGPUbackend.
Before using any graphical software, running these is esential and took a long
time to figure out.
I mentioned that the video codec acceleration drivers were impossible for me to 
find, which is why video playback went directly to software rendering. The way
I found to avoid this was using vo=xv in the mpv config, the entire conf being as
follows:
-----------------------------------------------------------------------------------
profile=fast
vo=xv
scale=bilinear
cscale=bilinear
video-sync=audio
framedrop=vo
cache=yes
cache-secs=10
volume-max=200(for good measure)

demuxer-max-bytes=50MiB
demuxer-max-back-bytes=20MiB(to prevent RAM leakage)
-----------------------------------------------------------------------------------
*Note: vo=xv means that the CPU decodes just the file and sends the raw data to the
GPU for RGB decoding, helping free up CPU cycles alot. That's apparently the
predeccessor to va-api.
This brought be some smooth video playback, but for local videos I went further 
and used the convert-to-mpeg2.sh tool, which shall be listed alongside this file
aswell. What it does is, you point it to the file in need of converting, it will
keep it's fps if lower than 48, or decrease to 48 if need be(if higher that is). 
It will make it fit a 1280x720 display whilst keeping the aspect ratio, convert 
the audio type, though I claim to not spot a quality difference in this realm, 
and of course, convert to Mpeg-2, which is much easier for the CPU to decode.


I also used alsa-utils for the audio managing. To set up the audio keyboard buttons
to control it correctly(they were set up for PipeWire), I edited the i3 config,
-----------------------------------------------------------------------------------
set $refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id amixer set Master 5%+ && \
$refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id amixer set Master 5%- && \
$refresh_i3status
bindsym XF86AudioMute        exec --no-startup-id amixer set Master toggle && \
$refresh_i3status
bindsym XF86AudioMicMute     exec --no-startup-id amixer set Capture toggle && \
$refresh_i3status
-----------------------------------------------------------------------------------

feh is used for the background, I used --bg-fill to see which picture I liked, 
then resized it with imageMagick to the proper size and then used --bg-center for
the actual output, as that avoids background scaling work:3
 
-------------------------USEFUL PRACTICES I LEARNED--------------------------------
For most of the debugging I used a terminal SSH window, sometimes many, as to 
observe system resource utilization via htop and intel_gpu_top. This also allowed
for easier copy-pasting outputs for help by chat clients, even though I condone
their usage(I am guilty of using them, I admit to my sins). Many times you will get
stuck in a loop where the chat will not be able to answer your question. Prepare a 
ready copy-paste-able wall of text explaining your entire setup as to make switching
clients easier. Using a MicroSD card is also extremely useful and enjoyable, I got
used to prefering it over USB, but that is personal preference. Using an E-thernet
cable to connect the 2 devices has massive influence over the ssh scp packet trans-
fer speed, can be useful on occasion.  USB headphones will NOT reliably work under
alsa-utils, enabling them for mpv playback took this command:
mpv --audio-device=alsa/hw:1,0 <file>, used aplay -l to gather that
amixer scontrols also shows all available audio devices apparently.

----------------------Daily usage!! For my own setup only---------------------------
After the login prompt, run 'startx' to start i3. Upon starting it, useful shortcuts
include:
$mod+Enter for a new terminal window
$mod+R, then arrows, to resize a window
$mod+shift+space to make a window floating
$mod+shift+Q to close a window
$mod+Shift+(arrows/number) to change window place/workplace
$mod+shift+E to log out
$mod+D to open a run dialog
$mod+shift+X/R to reload conf/i3
$mod+shift+c copies selected text to Clipboard      *Note:$Mod=Home key
After that, running properGPU will enable the gpu driver for only the terminal window
you run it in. 
Software is: ani-cli, ytbrowse, onda, concord, steamcmd, presenterm, sc-im, pixelart-tui
Games are in ~/Games
Movies are in ~/Videos/Movies, start with mpv command, 3.5mm headphones work out of
the box
For game emulation, there exist: Nestopia, fceux, wine(v4.0.4)
The last one isn't recommended.
Browsing is done via links2
Useful aliases include:
browse='links2 -g duckduckgo.com'
batteryInfo to show info with UPower
concordUpdate
neofetch, launches fastfetch

Use nmcli to connect to new wifi networks, cups for printers, lp <file> prints it,
brightnessctl(keyboard keys also work) for brightness.




I Really really hope this file helps someone out there save their own Netbook from the
E-Waste Pile! I know it's not greatly documented, it's late, I write this mostly to not
forget what I've done myself, but also because noone out there had done that prior,
at least to my knowledge. Message me if you want help for something I haven't listed,
I'm not all knowing but there are many many many tiny things that have taken me days to
figure out which I haven't remembered to list, such as the fact that Mesa 25 has i915
placeholder drivers that do nothing, or that Wine uses it's own paths which also need
to be exported etc. Good luck out there, and take care!<3

Additions:
If yt-dlp starts outputting errors, yt-dlp -U and yt-dlp --rm-cache-dir will fix this
mesa-utils:i386 needed to review if the i386 driver is working correctly
Though not relevant for my exact setup, for another legacy machine, during a setup
on the go, USB tethering from a mobile device served as E-Thernet connection, might
help somebody.
