# ctrun.sh - script to execute Docker containers configured from DNS

This script executes a container in a specific Docker network assigning a fixed IP address from DNS and mapping volumes to a specific local directory.

## Installation

Copy the script to `/usr/bin/local/` and edit it to change the network name, DNS server and data directory to match your needs.

## Usage

```
ctrun hostname [-av volume_path1[:options]] [docker run switches/options] image_name [command]
```

Example:

```bash
$ ctrun "www.example.com" -av /var/www apache2
```


# License

Licensed under GNU -- contributions welcome!!