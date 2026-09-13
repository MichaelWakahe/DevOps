# Linux Files

These are files with settings beyond the default.

## Tip: check laptop battery usage from the terminal

Run these commands on the **Linux laptop**, either locally or through an SSH session. They only read battery information
and do not require `sudo`.

### Check charge level and charging status

Read the battery information exposed by the kernel without installing additional tools:

```bash
for battery in /sys/class/power_supply/BAT*; do
    [ -d "$battery" ] || continue
    printf '%s: ' "$(basename "$battery")"
    cat "$battery/capacity" "$battery/status"
done
```

Example output:

```text
BAT0: 38
Discharging
```

This means the battery is at **38% charge** and is currently discharging. Other statuses include `Charging` and `Full`.
The loop reports each battery whose name starts with `BAT`.

If nothing appears, the system may use a different battery name or may not expose a battery through this interface.
List the available power supplies to inspect their names:

```bash
ls /sys/class/power_supply/
```

Not every entry is a battery; AC adapters may appear here too. Some devices may not provide `capacity` or `status`.

### Get more detail with UPower

If UPower is installed, list the power devices:

```bash
upower -e
```

Find the battery device path in the output, then inspect it. For example:

```bash
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```

Replace that example path with the battery path actually reported by `upower -e`.

| Field | Meaning |
| --- | --- |
| `percentage` | Current charge level. |
| `state` | Whether the battery is charging, discharging, or fully charged. |
| `time to empty` / `time to full` | Estimated remaining runtime or charging time, when available. |
| `capacity` | Battery health relative to its original design capacity, not its current charge percentage. |

UPower's `capacity` field differs from the kernel's `capacity` file above, which reports current charge percentage.
Runtime estimates vary with workload and may be unavailable. If `upower` is not installed, use the kernel interface
above for a basic reading.