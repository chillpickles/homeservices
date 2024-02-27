# [longhorn](https://longhorn.io/docs/1.6.0/deploy/install/#installing-open-iscsi)
## a distributed block storage system for Kubernetes

have to run stateful sets in kubernetes to run things, and you've really thought about how you would backup those files? network shares sound like buckets of fun to manage? lets see how much overhead this introduces into cluster performance!

## 20240216

[Installation Requirements](https://longhorn.io/docs/1.6.0/deploy/install/#installation-requirements) seem sane, some iscsi drivers, an nsfv4 client and some cli tools

- [iscsi on coreos](https://github.com/coreos/docs/blob/master/os/iscsi.md) is disabled by default sooooo, `systemctl enable iscsid`
  - nice lets fuck up this coreos node 
        
        systemctl enable rpcbind.service 
        systemctl enable rpc-gssd.service
        
- 🙃
- 

longhorn may misbehave on coreos I can feel it coming

- armbian
        
        sudo apt install open-iscsi

pulling `v1.6.0` of the longhorn manifests 

## 20240221

zero issues with coreos, I don't think I needed to enable these manually since the only nodes that have issues are the RPI etcd nodes. sick

trying to configure something to keep the longhorn pods from trying to start on the etcd (rpi) nodes, I don't think taints will work for this, and I don't want to use node selection - yet

## 20240223

thanks [Lawrence Systems](https://www.youtube.com/channel/UCHkYOD-3fZbuGhwsADBd9ZQ) for the [iops test script](https://forums.lawrencesystems.com/t/fio-bash-script-for-linux-storage-testing/19374)
IOPS - 
    rockpi-5b - nvme SSD
        Running randwrite test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Write IOPS: 540.41
        Average Write Bandwidth (MB/s): 540.41
        Running randread test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 1,466.87
        Average Read Bandwidth (MB/s): 1,466.87
        Running write test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Write IOPS: 613.11
        Average Write Bandwidth (MB/s): 613.11
        Running read test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 1,617.97
        Average Read Bandwidth (MB/s): 1,617.97
        Running readwrite test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 350.13
        Average Write IOPS: 366.08
        Average Read Bandwidth (MB/s): 350.13
        Average Write Bandwidth (MB/s): 366.08

    zmhblue-controlplane-001 - SATA HDD
        Running randwrite test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Write IOPS: 82.65
        Average Write Bandwidth (MB/s): 82.65
        Running randread test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 101.46
        Average Read Bandwidth (MB/s): 101.46
        Running write test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Write IOPS: 123.58
        Average Write Bandwidth (MB/s): 123.58
        Running read test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 129.36
        Average Read Bandwidth (MB/s): 129.36
        Running readwrite test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 65.31
        Average Write IOPS: 68.29
        Average Read Bandwidth (MB/s): 65.31
        Average Write Bandwidth (MB/s): 68.29

    zmh-blue-001 - nvme SSD
        Running randwrite test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Write IOPS: 2110.88
        Average Write Bandwidth (MB/s): 2110.88
        Running randread test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 2683.15
        Average Read Bandwidth (MB/s): 2683.15
        Running write test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Write IOPS: 2176.82
        Average Write Bandwidth (MB/s): 2176.82
        Running read test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 2732.46
        Average Read Bandwidth (MB/s): 2732.46
        Running readwrite test with block size 1M, ioengine libaio, iodepth 16, direct 1, numjobs 5, fsync 0, using 5 files of size 1G on /home/
        Average Read IOPS: 1077.11
        Average Write IOPS: 1126.17
        Average Read Bandwidth (MB/s): 1077.11
        Average Write Bandwidth (MB/s): 1126.17

these results seem to be halving the iops? idk what iops is I just work here

cool so, now to follow the ingress instructions:

        USER=<USERNAME_HERE>; PASSWORD=<PASSWORD_HERE>; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth