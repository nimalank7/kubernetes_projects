# Linux routing example

```mermaid
flowchart LR
    subgraph Host["Host"]
        direction TB
        subgraph HOST_NS["Host network namespace"]
            direction LR
            HOST_HEADER["Host network namespace"]
            BR0["br0\nIP: 10.0.0.1/24"]
            subgraph CONTAINER1["Container network namespace"]
                C1["veth-con\nIP: 10.0.0.11/24"]
            end
            ENP["enp0s8: 192.168.68.1"]
        end
    end

    BR0 --> HOST_HEADER[" "]
    BR0 <-->|"veth pair"| C1
    style HOST_HEADER fill:none,stroke:none,color:transparent
```

IP forwarding enables Linux to forward packets. Since the destination IP address is on the host the destination MAC address is set to the bridge (`46:84:35:92:77:db`). Layer 2 traffic is sent from the namespace through the bridge using the default route `10.0.0.1` which is then forwarded to the `enp0s8` interface.

## Test connectivity

```bash
vagrant ssh
sudo ip netns exec container ip route
sudo ip netns exec container ping -c 4 192.168.68.1
```

Inside the `container` namespace, attempt to `ping` the `enp0s8` interface on `192.168.68.1`.