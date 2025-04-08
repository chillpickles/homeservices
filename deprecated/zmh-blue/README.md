# k3s 20230925

Due to sysadmin incompetence, the VLAN configuration in Unifi kinda fucking broke everthing, continually for about 2 months
That iteration has been reset entirely

The new entertainment center/isp equipment rack is installed and functional which means I have a few options for how I structure my rack that holds the clustered devices and storage appliances, and how the rest of my network devices are managed. 

I'll try to journal in this README as I continue the rebuild

# truenas 20231108

Ideally - TrueNAS implementations would bridge the gap between a synology appliance and a fully configured ProxMox hypervisor by acting as a host for services like s3 buckets, DB instances, and some VMs to use as kubernetes nodes. Building this been interesting.

BIOS updates, PCIE Bifurcation and configuration have made the Hyve Zeus boxes work well for this, working through TrueNAS configuration has not been as seamless as I'd hoped. 
    - TrueNAS Scale implements a single node kubernetes cluster and uses helm charts to deploy apps - probably a great implementation
    for the developers that have to maintain those tools, but bad for me a consumer who is comfortable working around kubernetes
    abstractions when it comes to networking, storage etc and a limited number of gotchas
    - TrueNAS Core is built on FreeBSD and doesn't support LXC containers out of the box. Meaning that I'm stuck running
    their plugins in BSD jails, not ideal for long term support 

# holy shit that burned me for 2 months? 20240126

okay new idea - k3s is great and I should just build from this and maybe add a hypervisor box later

https://docs.k3s.io/architecture

they support both `server` and `agent` nodes. they also support experimental modes like
- agentless servers 
  - *fascinating, maybe I could run a management layer on my rpis with laptop drives and then add beefy nodes in as I need them*
- external DB
  - *great idea, just like I wanted with truenas was to have a managed DB appliance but I could maybe run it on my new rk3855 nas*
- dedicated etcd nodes *interesting*
  - https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
  - supported in k3s https://docs.k3s.io/installation/server-roles

sticking to k3s and avoiding an external DB for now - maybe I can build a longer term management layer after all my rpis aren't running on sd cards. The only things I need to figure out are a fixed registration address, or some sort of load balancing for the etcd cluster

`--etcd-servers=$LB:2379`

`--tls-san value`

fucking.. okay how much am I invested in loadbalancing to these nodes in case my VLANs die again 🙃. So my snowflake instance could be my NAS appliance with 4 drives, running a little nginx box that just.. needs to have records updated to point at my particular management interface https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/. this would probably fix my issue where the VLANs died, none of the k3s certificates are valid anymore so I can't reach the nodes (I could have probably fixed this by editing config files and systemd stuff but fuck you)

wait couldn't I just hack this with DNS, because I can point a record at any of the goddamn nodes? https://docs.k3s.io/datastore/ha-embedded https://docs.k3s.io/cli/server?_highlight=tls&_highlight=san#listeners `... N/A	Add additional hostnames or IPv4/IPv6 addresses as Subject Alternative Names on the TLS cert` 

great, manually updated DNS records *definitely not shopping for used hardware loadbalancers*

yeah okay, I should just.. write some coreos ignition files, fuck

# ignition files 20240128

https://discussion.fedoraproject.org/t/fcos-unusually-slow-on-raspberry-pi-3b/40635


rpi3 with coreos is underway - idk how I didn't know what this UEFI firmware image was but [saving this for later](https://github.com/pftf/RPi3?tab=readme-ov-file) - now to get my pineh64 boards working 🫠

# 20240202

arm is strange, i'm trying to learn what UEFI booting even is I guess? the pis don't like to boot from the disc drive once coreOS  is written to it so - unfortunate. Guess we'll try the pine boards. This is fwupdmgr get-upgradeslikely a consequence of using arm boards which not every aarch64 image will support

[pineh64b u-boot](https://github.com/as365n4/update_U-Boot_on_Device/blob/c7d9bd6523967e2cb89837f22ebea89f03f657c3/arm64%20update%20U-Boot%20on%20device%20(PineH64B).pdf) just need to `sudo apt install python3-setuptools` as well. This is promising maybe, if the Pine Boards cooperate with CoreOS I can keep the pis on raspbian where they're happiest

# 20240206

remember kids, `.img.xz` images need to be unzipped before you write them to drives. that's why this was so fast and simple to dd these images before lmao

# 20240209

I have climbed 1000 steps going back and forth between my desk and my rack. Up and down the stairs, consulting the laptop plugged into the switch and then the chrome tabs I have open. I have slain the VLAN beast and FINALLY FUCKING gotten my shit working somewhat reasonably. the USG routers have LAN2 default as a voice network for some fucking reason, and going between unifi's dubious VLAN settings, and mikrotik's 90s aesthetic really has not made VLAN setup easier. 

Since I'm not doing router on a stick my setup is


    wan {
      USG_PRO_4 { # please god will you bless me with the strength to spend the money on a router that can handle a 5G fiber uplink
        LAN1 {
          USW_24 [
            VLAN 10,
            VLAN 20,
          ]
        }
        LAN2 {
          CSS326 [
            VLAN 30,
          ]
        }
      }fwupdmgr get-upgrades
    }

The Mikrotik switch ([SwOS](https://wiki.mikrotik.com/wiki/SwOS/CSS326)) expects the ingress SFP port to have DefaultVLAN set to `[1]` and the rest of the ports set to DefaultVLAN `[30]` with VLAN Mode `[enabled]` on all of them to make sure that all the devices plugged into the egress ports are "on" `VLAN30`. The VLANs tab has all of the VLANs added to this list, and currently all of them are allowed to reach the ports - *my access from the home network side is going to take some time to develop*. Since `LAN2` in the `USG` requires a VLAN be set for a `network` on that interface, it is set to `VLAN30` by default, which means that *tagged traffic will be sent over to `VLAN30` -> `LAN2` -> `CSS326` -> and then allowed to reach the machines on the access ports which allow `VLAN30`*

WHY the ingress port is set to `[1]` I could not coherently [explain](https://wiki.mikrotik.com/wiki/SWOS/CSS326-VLAN-Example), so someone please give me another basics course thanks.

anyways fuck this shit, where are those goddamn k3s commands

# 20240210

fixing this VLAN mess in my home network has revived the `zmh-green` cluster which is both astounding, delightful and terrifying. updating the unifi controller image, putting the backup into it and being able fwupdmgr get-upgradesto use the mobile app again for the first time in like a year feels very nice

all of the kubernetes services have survived, my first working ingress controller and my sadge attempts to get cert-manager working. since I've got the RPIs working as the etcd cluster, we're gonna be adding a control plane node using some old old sff PCs with i3s that can act as control plane

# 20240213

cgroups on armbian do not work. CGROUPS ON ARMBIAN DO NOT WORK, DO NOT RUN ARMBIAN ON RPI3B+ BOARDS, IT WILL NOT WORK, THERE IS NOT A MAGICAL LINK HERE TO HELP YOU FIX THIS ISSUE, JUST ROLL OVER AND LET RASPIOS DO THE WORK FOR U

armbian on the rock5 is decent so far, we'll see if there are any memory issues with it or the RK3588 NAS board
  - `update`, there are literally no issues

troubleshooting the commands I'm running to install k3s with the flags I want AND splitting up node roles, lots of uninstalling, checking network connectivity and other fun stuff to get k3s functional. mostly me figuring out how to format the commands, running uninstalls and reinstalls parallel. lots of cursing.

`zmh-blue>bootstrap>k3s.md` to document getting this working with the architecture I want

cluster work, now to make cluster do work

    hmm well you know I was thinking abt getting longhorn working, and seeing if I could automate my hyve zeus boxes to spin up and down on a schedule 🫦 and I have this little rk3588 NAS to configure.. kubernetes operators first I guess

# 20240215

followed the ubuntu installer to use LVM volumes? [deactivate those bitches](https://forum.level1techs.com/t/unmount-unmap-lvm-volumes/185342)
     ```If you run lvs you’ll see the Attr column, this is a bunch of flags showing stats per LV. If the Attr column shows “a”, then the LV is “active” and can be mounted. To fully unmount a drive you need to deactivate the LV, usually with lvchange -an vg/lv and/or the entire VG with vgchange -an vg/lv. A deactivated LV will not show “a” in the Attr column.

    Once the LV and VG have been deactivated it’s safe to remove the disk. Though in general I don’t bother deactivating LVs/VGs for removable drives, simply unplugging it is fine.```


# 20240312

longhorn controller manifests have been written, working to deploy a minecraft server and start testing my mental sanity when managing these volumes. Until I have minio setup in the home network I don't think I want to run it with terraform, so helm configs for kube-prometheus-stack will be done with just a values file and `helm` commands

# 20240313

all of the k8s controllers are setup and working as expected, kubeflare and cert-manager are next after I provision some game servers.

# 20250202

this shit got dropped cuz I bought a house

so far we have:
 - massively upgraded our unifi gear, we're now 10gig LAN capable, and we have capability to integrate unifi-protect
 - upgraded from LTE to gigabit fiber
 - kept the synology box alive, with a hot spare no less
 - killed another proxmox boot drive
 - gotten some of the old 7000 series intel processors into motherboards that work
 - gotten a pcie extension so that we can get the dual node rackmount case running

new house has an office with a RACK IN IT, and NO STAIRS to run up and down so troubleshooting will only be slightly less annoying. the KVM I have doesn't really support HDMI, and I haven't tried to convert everything to DVI yet so we still rock the screen sitting on the ground, and the $5 keyboard for manual bullshit

the `zmh-blue` cluster died in the old house cuz whatever hacky etcd only shit I put on the rpis died, which tanked my desire to run a kubernetes cluster without doing [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) so that we can learn exactly, precisely how to manage the different components of a kubernetes cluster. 

# 20250310

- tested kubernetes the hard way, and honestly I've learned way more from doing that than messing with k3s. I have to recommend this as a step in learning k8s going forward. 
- running an etcd cluster separately from master nodes doesn't sound right anymore, and ignores the point of bundling the components of your control plane onto your nodes
- I could try patching together my own control plane cluster from scratch, but k3s seems like it's going to massively simplify that and allow uninstall super easy as well

k8s-the-hard-way covers bootstrapping a cluster, which starts with creating a CA that the rest of the cluster certs are signed by. I'm not at all ready to start managing a CA out of band, and relying on k3s to generate the certs, rotate them as needed and keep the etcd cluster internal to the server nodes makes the most sense for now. We'll just have to implement better backups for the etcd store, ensuring that they get copied out to OMV or Synology

Shit, I mean the sizing guide scales 1 RPI to 350 agents?
|Server CPU |	Server RAM |	Number of Agents |
|-----------|------------|-------------------|
|2 |	4 GB |	0-350 |
| 4	| 8 GB	| 351-900 |
| 8	| 16 GB	| 901-1800 |
| 16+	| 32 GB	| 1800+ |

sure the 3b+ rpi only has 3GB of ram, but sheiiiitt I'm overthinking this HA control plane shit. I can run the 3 pis as the base cluster, and add on more compute as I need, OMV will be the backup to the cluster and bing bang boom
why even have these big ass zeus boxes, I'll probably literally never do anything with them 😢

so we want to run 1 server and 1 agent node since this will be a "managemnent cluster" of sorts, and I'll deal with setting up a miniPC for a services cluster later
rpi-001 - server
rpi-002 - agent1

# 20250316

rpi3b+ cannot run as the master nodes, swapping to rpi-004(rpi5, 4gb) as master node

# 20250323

the pi3bs are not able to run minio, so I'm going to have to move on to the rk5b board for a little more oomph