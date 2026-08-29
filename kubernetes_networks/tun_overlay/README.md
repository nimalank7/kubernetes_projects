# Overlay network with TUN interfaces

```mermaid
flowchart TB
    subgraph DC1["Host A"]
        direction TB
        subgraph HOST_A["Host network namespace"]
            direction TB
            HOST_HEADER_A["Host network namespace"]
            subgraph CONTAINER1["NS1 network namespace"]
                C1["veth-con-1\nIP: 172.16.0.2"]
            end
            subgraph CONTAINER2["NS2 network namespace"]
                C2["veth-con-2\nIP: 172.16.0.3"]
            end
            TUN1["TUN\nIP: 172.16.0.100/16"]
            IF1["enp0s8\nIP: 10.0.0.1/24"]
            BR1["br-overlay\nIP: 172.16.0.1"]
        end
    end

    subgraph DC2["Host B"]
        direction TB
        subgraph HOST_B["Host network namespace"]
            direction BT
            HOST_HEADER_B["Host network namespace"]
            subgraph CONTAINER3["NS1 network namespace"]
                C3["veth-con-1\nIP: 172.16.1.2"]
            end
            subgraph CONTAINER4["NS2 network namespace"]
                C4["veth-con-2\nIP: 172.16.1.3"]
            end
            TUN2["TUN\nIP: 172.16.1.100/16"]
            IF2["enp0s8\nIP: 10.0.0.2/24"]
            BR2["br-overlay\nIP: 172.16.1.1"]
        end
    end

    DC1 <-->|"UDP tunnel"| DC2
    BR1 --> HOST_HEADER_A[" "]
    style HOST_HEADER_A fill:none,stroke:none,color:transparent
    BR1 <-->|"veth pair"| C1
    BR1 <-->|"veth pair"| C2
    BR2 --> HOST_HEADER_B[" "]
    style HOST_HEADER_B fill:none,stroke:none,color:transparent
    BR2 <-->|"veth pair"| C3
    BR2 <-->|"veth pair"| C4
```

Bridges and TUN on both `host_a` and `host_b` are on an overlay network (`172.16.1.100/16`). The underlay network for `enp0s8` are on a underlay network (`10.0.0.0/24`). `socat` then encapsulates packets that arrive on `TUN` into a UDP packet and sends it out of `enp0s8`.

## Setup UDP tunnels

Run the following on Host 1:

1. Setup the UDP tunnel on `host_a`

```
vagrant ssh host_a
sudo socat UDP:10.0.0.2:9000,bind=10.0.0.1:9000 TUN:172.16.0.100/16,tun-name=tundudp,iff-no-pi,tun-type=tun &
ip tuntap
```

2. Setup the UDP tunnel on `host_b`

```
vagrant ssh host_b
sudo socat UDP:10.0.0.1:9000,bind=10.0.0.2:9000 TUN:172.16.1.100/16,tun-name=tundudp,iff-no-pi,tun-type=tun &
ip tuntap
```

3. Turn on TUN device on `host_a`

```
vagrant ssh host_a
sudo ip link set dev tundudp up
```

4. Turn on TUN device on `host_b`

```
vagrant ssh host_b
sudo ip link set dev tundudp up
```

## Test connectivity

```
vagrant ssh host_a
sudo ip netns exec NS1 ping -c 4 10.0.0.2
```

Inside `host_a` attempt to `ping` the node IP on `host_b`.

```
vagrant ssh host_a
sudo ip netns exec NS1 ping -c 4 172.16.1.2
```

Inside `host_a` attempt to `ping` the IP in a namespace on `host_b`.