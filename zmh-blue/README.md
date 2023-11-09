# k3s 20230925

Due to sysadmin incompetence, the VLAN configuration in Unifi kinda fucking broke everthing, continually for about 2 months
That iteration has been reset entirely

The new entertainment center/isp equipment rack is installed and functional which means I have a few options for how I structure my rack that holds the clustered devices and storage appliances, and how the rest of my network devices are managed. 

I'll try to journal in this README as I continue the rebuild

# truenas 20231108

Ideally - TrueNAS implementations would bridge the gap between a synology appliance and a fully configured ProxMox hypervisor by acting as a host for services like s3 buckets, postgres DB instances, and some VMs to use as kubernetes nodes. Doing so has been interesting.

BIOS updates, PCIE Bifurcation and configuration have made the Hyve Zeus boxes work well for this, working through TrueNAS configuration has not been as seamless as I'd hoped. 
    - TrueNAS Scale implements a single node kubernetes cluster and uses helm charts to deploy apps - probably a great implementation
    for the developers that have to maintain those tools, but bad for me a consumer who is comfortable working around kubernetes
    abstractions when it comes to networking, storage etc and the gotchas that are involved with the trickery I like doing
    - TrueNAS Core is built on FreeBSD and doesn't support LXC containers out of the box. Meaning that I'm stuck running
    their plugins in BSD jails, not ideal for long term support 

