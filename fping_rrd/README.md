# fping-rrd :: fping rrd helper script

Latency mesuring & visualization scripts that use fping and rrdtool.

## File List

| File | Description |
| :--- | :--- |
| fping_rrd.sh | FPing data collector for rrdtool. |
| graph_mini.sh | mini png graph from an .rrd file |
| graph_multi.sh | single png from multiple .rrd files |
| graph_smoke.sh | smokeping graph from an .rrd file |

## Crontab Example

```crontab
*/5 * * * *     ${HOME}/fping_rrd.sh 192.0.2.1 192.0.2.2
```
