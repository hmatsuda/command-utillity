#!/bin/sh

# size (in GB) that is larger than the current size
instanceid=$1
size=$2

# Get the root EBS volume id and availability zone for this instance
oldvolumeid=$(ec2-describe-instances $instanceid | egrep "^BLOCKDEVICE./dev/sda1" | cut -f3)
zone=$(ec2-describe-instances $instanceid | egrep "^INSTANCE" | cut -f12)
echo "instance $instanceid in $zone with original volume $oldvolumeid"

# Stop (not terminate!) the instance
ec2-stop-instances $instanceid

# Detach the original volume from the instance
while ! ec2-detach-volume $oldvolumeid; do sleep 1; done

# Create a snapshot of the original volume
snapshotid=$(ec2-create-snapshot $oldvolumeid | cut -f2)
while ec2-describe-snapshots $snapshotid | grep -q pending; do sleep 1; done
echo "snapshot: $snapshotid"

# Create a new volume from the snapshot, specifying a larger size
newvolumeid=$(ec2-create-volume --availability-zone $zone --size $size --snapshot $snapshotid | cut -f2)
echo "new volume: $newvolumeid"

# Attach the new volume to the instance
ec2-attach-volume --instance $instanceid --device /dev/sda1 $newvolumeid
while ! ec2-describe-volumes $newvolumeid | grep -q attached; do sleep 1; done

# Start the instance and find its new public IP address/hostname. (If you were using an elastic IP address, re-assign it to the instance)
ec2-start-instances $instanceid
while ! ec2-describe-instances $instanceid | grep -q running; do sleep 1; done
ec2-describe-instances $instanceid
