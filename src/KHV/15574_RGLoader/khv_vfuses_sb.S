# Builds 15574 RGLoader KHV patches with VFuse support and HDD file redirection
# for small block (16mb) consoles. Base = 15574_XDKBuild + RGLoader 0v305 additions.
# HDD needs \Filesystems\15574-dev\ (see inc/sysroot_hdd.S)

.set vfuses, 1
.set hdd, 1
.set rgl, 1
.set kd_1retry, 1

# Optional:
# .set disable_bootanim, 1   # only if using RGL_bootanim.xex from rgloader.ini
# .set rgl_skip_6a68, 1      # drop the HV 0x6A68 nop (review item)
# .set rgl_skip_218, 1       # drop the HV 0x218 MachineCheck patch (review item)

.include "khv_15574.S"
