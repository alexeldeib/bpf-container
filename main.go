package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/jaypipes/ghw"
	"github.com/sanity-io/litter"
	"k8s.io/kubernetes/pkg/util/mount"
)

func main() {
	var mode os.FileMode = 0644
	if err := os.Mkdir("/mnt/disks", mode); err != nil {
		log.Println(err)
	}
	mounter := mount.New("")
	block, err := ghw.Block()
	if err != nil {
		fmt.Printf("Error getting block storage info: %v", err)
	}

	fmt.Printf("%v\n", block)

	for _, disk := range block.Disks {
		litter.Dump(disk)
		if len(disk.Partitions) == 0 && strings.Contains(disk.Name, "nvme") {
			devicePath := fmt.Sprintf("/dev/%s", disk.Name)
			mountPath := fmt.Sprintf("/mnt/disks/%s", disk.Name)
			if _, err := os.Stat(mountPath); os.IsNotExist(err) {
				if err := os.Mkdir(mountPath, mode); err != nil {
					log.Printf("error making dir: %v", err)
					os.Exit(1)
				}
			}
			if out, err := exec.Command("mkfs", "-t", "xfs", "-f", devicePath).CombinedOutput(); err != nil {
				log.Printf("error making fs: output: %s\n, error: %v", out, err)
				os.Exit(1)
			}
			if err := mounter.Mount(devicePath, mountPath, "xfs", []string{}); err != nil {
				log.Printf("error making mount: %v", err)
			}
		}
	}
}
