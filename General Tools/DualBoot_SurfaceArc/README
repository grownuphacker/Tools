# Pair a Surface ARC in both OS's

I forked this from somewhere.  I'll try to remember to update this with the source. 

1.  Pair your mouse in Linux
2.  Reboot, Pair in Windows (this will kill the windows version)p
3.  Reboot, leave your mouse off
4.  Mount your windows partition, may need to remove the hiberfile
  `mount /dev/nvme01p04 /media/primary -t ntfs-3g -o remove_hiberfile`  (doublecheck this, its from memory)
5.  use / install chntpw `sudo apt install chntpw`
6.  `python3.7 export-ble-infos.py --system /media/primary/Windows/System32/config/SYSTEM --template surface_arc_template`
7.  Backup your old pairing, just in case `mv /var/lib/bluetooth/_YOURMAC_ ~/Downloads/YOURMAC.OLD`
8.  Copy your new export to blueooth dir `cp bluetooth/_YOURMAC_ /var/lib/bluetooth/` 
9.  `service bluetooth stop && service bluetooth force-reload && service bluetooth start`

## Something like that. 
Note:  Dragons do be here. 
