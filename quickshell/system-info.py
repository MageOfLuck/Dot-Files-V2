#!/usr/bin/env python3
"""Small read-only Linux dashboard snapshot; no third-party dependencies."""
import json
import os
import socket
from pathlib import Path

seconds = int(float(Path('/proc/uptime').read_text().split()[0]))
mem = {line.split(':')[0]: int(line.split()[1]) for line in Path('/proc/meminfo').read_text().splitlines()}
total = mem['MemTotal']
used = total - mem['MemAvailable']
print(json.dumps({
    'host': socket.gethostname(),
    'uptime': f'{seconds // 86400}d {(seconds // 3600) % 24}h {(seconds // 60) % 60}m',
    'memory': f'{used / 1048576:.1f} / {total / 1048576:.1f} GiB ({used / total:.0%})',
    'load': ', '.join(f'{value:.2f}' for value in os.getloadavg()),
}))
