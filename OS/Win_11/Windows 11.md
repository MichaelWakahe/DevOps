# Windows 11

## Map a hostname to an IP address

Add a static hostname mapping to the Windows hosts file so this computer resolves `hp-omen` to `192.168.50.88`.

1. Open **Windows Terminal (Admin)** and use a PowerShell tab.
2. Run the following commands once to append the mapping and clear the DNS cache:

   ```powershell
   Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "`n192.168.50.88 hp-omen"
   ipconfig /flushdns
   ```

3. Confirm hostname resolution:

   ```powershell
   ping hp-omen
   ```

   The output should show `Pinging hp-omen [192.168.50.88]`. Ping replies may time out if the device blocks ICMP; the displayed IP address confirms hostname resolution.

This mapping applies only to the computer whose hosts file you edited. Reserve `192.168.50.88` for the target device in your router's DHCP settings so it does not receive a different IP address later.

If the hosts file already contains an entry for `hp-omen`, edit that entry as an administrator instead of appending another one.
