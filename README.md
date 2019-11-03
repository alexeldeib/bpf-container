# disk-playground

This repository is a playground for using nvme ssds and other high i/o devices on AKS clusters.

The manifests directory containers a pod which will format and mount all nvme drives as xfs. From there, the provisioner pod (also in the manifests) will convert all disks to PVs available for consumption.

Additionally, one pod in the manifests directory consumes a drive as an example. 

main.go simply looks for unmounted/unformated nvme drives and adds them by their name under /mnt/disks/
