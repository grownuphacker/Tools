# Tools
A few things I've slapped together over time.  I hope you find them useful.
For you blueberries, just [Download](https://github.com/BlueTeamNinja/Tools/archive/master.zip "The path to greatness")  from here.  

This list is getting outdated - There are more than this and I haven't written about them all yet.  

**Script** | What it does... | Requisites
---|---|---:
||<h2> *AD Tools* |
  **Intentional-Lockout** |  Locks out a specified account.  Used to test Event alerting, WMI query testing, and SIEM trigger. | *None*
 **Get-QuickPCInfo** |  Toss in hostnames and glob together logged in User, with some AD details. | *None*
||<h2> General Tools|
**SMS Alert** | Because a tsunami of emails **AFTER** you've fixed exchange saying "*Exchange is down*" is just embarassing.  | *None*
**Mass E-Mailer** | *Coming soon - still scrubbing*, internal tool for emailing PoSH objects in bulk, grouped by an item (Usually a person, group by Supervisors etc).  | *NA*
**Open Ports** | _Netstat is boring_.  Lucky for you, I'm not.  I just added a bit of tweak for some decent info for listening ports. | *None*
**Firefox Details** | I needed it once, I'm sharing it now.  Hunts versions of 32 or 64-bit for SCCM detection or whatever. | *None*
**Enable Copy/Paste** | Enable 'isolation.tools.copy.disable' eq FALSE on VMS by Wildcard. | **PowerCLI**
||<h2> Ninja Bucket (In Progress)|
**View Agent Logs** | Parsing out connection times regardless of protocol (PCoIP, RDP, etc). It's a snitch report.  | *Horizon View Agent 4.X+*
**Nuketown** | Pass an app string, easily signed, and nuke all instances on a remote PC (I.e. Java, Oracle, TightVNC).  Easy pave for SCCM. | *A pulse*
**Email Rescue Ops** | Exchange likes to topple over, and people get all uppity.  This is a somewhat frequence cause, and an auto-doc to fix it.  | *On Prem Exchange*


