# Hardware h264 encoding using vaapi

### Original Project Description
This plugin is designed to enable hardware-accelerated transcoding profiles using VAAPI (Video Acceleration API) on Linux systems. It's important to note that this is an experimental test project , and significant tinkering will likely be necessary to get it working properly with your specific hardware configuration.

For more information on vaapi and hardware acceleration:

- https://jellyfin.org/docs/general/administration/hardware-acceleration.html#enabling-hardware-acceleration
- https://wiki.archlinux.org/index.php/Hardware_video_acceleration#Comparison_tables

## Running the Docker image

Official PeerTube Docker images do **not** ship with the required libraries for hardware transcoding.
To enable VAAPI hardware acceleration, you must use the **custom image** provided by this repository.

### Image selection

- **Intel Gen 8 and newer** → use the `ihd` image tag
- **Intel Gen 7 and older** → use the `i965` image tag

Replace `chocobozzz/peertube:production-trixie` with `ghcr.io/althafvly/peertube-vaapi:production-trixie-ihd` or `ghcr.io/althafvly/peertube-vaapi:production-trixie-i965`

### Render group ID

The container must be added to the host `render` group.
You need to provide the **numeric ID** of this group.

You can retrieve it with the following command:

```bash
grep "$(ls -l /dev/dri/renderD128 | awk '{print($4)}')" /etc/group | cut -d':' -f3
```

```yaml
    # usual peertube configuration
    # ...

    # add these keys
    group_add:
      - <replace with the id of the render group>
    devices:
      # VAAPI Devices
      - /dev/dri:/dev/dri
```
---

## Installing the PeerTube VAAPI plugin

The Docker image only provides the **system-level VAAPI dependencies**.
The actual hardware-accelerated transcoding profiles are provided by a PeerTube plugin and must be installed **manually from the PeerTube admin interface**.

### Steps

1. Log in to PeerTube as an **Administrator**
2. Go to **Settings**
3. Open **Plugins/Themes**
4. Switch to the **Search Plugins** tab
5. Search for:

   ```
   ffmpeg-vaapi
   ```

6. Click **Install**
7. Enable the plugin after installation in **Installed Plugins**
