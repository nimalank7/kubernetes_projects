# Bridge network setup

```mermaid
flowchart LR
    subgraph Host["Host"]
        direction TB
        subgraph HOST_NS["Host network namespace"]
            direction LR
            HOST_HEADER["Host network namespace"]
            subgraph BRIDGE["Bridge"]
                direction TB
                BR0["br0\nIP: 10.0.0.1/24"]
                VETH_H1["veth-host-1"]
                VETH_H2["veth-host-2"]
            end
            subgraph CONTAINER1["Container 1 network namespace"]
                C1["veth-con-1\nIP: 10.0.0.11/24"]
            end
            subgraph CONTAINER2["Container 2 network namespace"]
                C2["veth-con-2\nIP: 10.0.0.12/24"]
            end
        end
    end

    BR0 --> HOST_HEADER[" "]
    style HOST_HEADER fill:none,stroke:none,color:transparent
    VETH_H1 <-->|"veth pair"| C1
    VETH_H2 <-->|"veth pair"| C2
```

This example creates two Linux network namespaces (`container1` and `container2`) and a veth pair. The veth pair is attached to the bridge which enables traffic to be routed between them.

## Test connectivity

```bash
vagrant ssh
sudo ip netns exec container1 ping -c 4 10.0.0.12
```

Inside the `container1` namespace attempt to `ping` the `container2` namespace