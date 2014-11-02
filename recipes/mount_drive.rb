
mount_point = node[:env][:mount_point]

# create a filesystem
execute 'mkfs' do
  command "mkfs -t ext4 #{device_id}"
  # only if it's not mounted already
  not_if "grep -qs #{mount_point} /proc/mounts"
end

# now we can enable and mount it and we're done!
mount "#{mount_point}" do
  device device_id
  fstype 'ext4'
  options 'noatime,nobootwait'
  action [:enable, :mount]
end
