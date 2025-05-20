import subprocess
import re


result = subprocess.run(["xrandr", "--current"], capture_output=True)

name_pattern = re.compile("^([\w\d-]+) connected.*")
mode_pattern = re.compile("^([\w\d-]+) connected.*")

displays = {}

lines = result.stdout.decode().splitlines()
while lines:
    line = lines.pop(0)
    if match := name_pattern.search(line):
        while lines:
            line = lines.pop(0)
            if not line.startswith(" "):
                lines.insert(0, line)
                break
            resolution, *rates = line.split()
            resolution = tuple(map(int, resolution.split("x")))
            print(match.group(1), resolution, rates)
