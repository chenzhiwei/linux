# Mount

## Bind mount

Sometimes you may need bind mount, run:

```
mount --bind /data/docker /var/lib/docker
```

In the `/etc/fstab`:

```
/data/docker /var/lib/docker none defaults,bind 0 0
```
