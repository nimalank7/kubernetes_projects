export NS1="NS1"
export NS2="NS2"
export NODE_IP="10.0.0.1"
export BRIDGE_IP="172.16.0.1"
export IP1="172.16.0.2"
export IP2="172.16.0.3"

echo "Installing socat"
apt-get update && apt-get install -y socat

echo "Creating the namespaces"
ip netns add $NS1
ip netns add $NS2

echo "Creating the veth pairs"
ip link add veth-host-1 type veth peer name veth-con-1
ip link add veth-host-2 type veth peer name veth-con-2

echo "Connect container ends to the namespaces"
ip link set veth-con-1 netns $NS1
ip link set veth-con-2 netns $NS2

echo "Assign IP addresses to the container ends"
ip netns exec $NS1 ip addr add $IP1/24 dev veth-con-1 
ip netns exec $NS2 ip addr add $IP2/24 dev veth-con-2 

echo "Turn on container ends"
ip netns exec $NS1 ip link set dev veth-con-1 up
ip netns exec $NS2 ip link set dev veth-con-2 up

echo "Creating the bridge"
ip link add name br0 type bridge

echo "Adding the network namespaces interfaces to the bridge"
ip link set dev veth-host-1 master br0
ip link set dev veth-host-2 master br0

echo "Assigning the IP address to the bridge"
ip addr add $BRIDGE_IP/24 dev br0

echo "Enabling the bridge"
ip link set dev br0 up

echo "Turn on host ends"
ip link set dev veth-host-1 up
ip link set dev veth-host-2 up

echo "Setting the loopback interfaces in the network namespaces"
ip netns exec $NS1 ip link set lo up
ip netns exec $NS2 ip link set lo up

echo "Add default routes to the bridge in the network namespaces"
ip netns exec $NS1 ip route add default via $BRIDGE_IP dev veth-con-1
ip netns exec $NS2 ip route add default via $BRIDGE_IP dev veth-con-2

echo "Enable IP forwarding on the node"
sysctl -w net.ipv4.ip_forward=1