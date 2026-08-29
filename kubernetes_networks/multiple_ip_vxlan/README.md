# Multiple IP addresses VXLAN setup

```mermaid
flowchart TB
    subgraph DC1["host_a"]
        direction TB
        HOST_HEADER_1["Host network namespace"]
        VTEP1["VTEP\nIP: 10.0.0.1"]
        IF1["enp0s8\nIP: 10.0.0.1/24\nSecondary IP: 192.200.0.1/24"]
        BR1["br-overlay\nIP: 10.200.0.1/24"]
    end

    subgraph DC2["host_b"]
        direction TB
        HOST_HEADER_2["Host network namespace"]
        VTEP2["VTEP\nIP: 10.0.0.2"]
        IF2["enp0s8\nIP: 10.0.0.2/24\nSecondary IP: 192.200.0.2/24"]
        BR2["br-overlay\nIP: 10.200.0.2/24"]
    end

    BR1 --> HOST_HEADER_1[" "]
    style HOST_HEADER_1 fill:none,stroke:none,color:transparent
    BR2 --> HOST_HEADER_2[" "]
    style HOST_HEADER_2 fill:none,stroke:none,color:transparent
    DC1 <-->|"UDP tunnel"| DC2
    BR1 --> VTEP1
    BR2 --> VTEP2
```

Bridges on both `host_a` and `host_b` are on an overlay network (`10.200.0.0/24`). Here `enp0s8` has a secondary IP address which is used for the underlay network for the VTEPs. VTEP encapsulates the Layer 2 packets and sends it from `enp0s8`.

## Test connectivity

```bash
vagrant ssh host_a
ping -c 4 10.200.0.2
```

Inside `host_a` attempt to `ping` the bridge on `host_b`.