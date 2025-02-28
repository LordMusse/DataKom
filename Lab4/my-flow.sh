#arp packets are small and could therefore benefit low latency(link 3)
sudo ovs-ofctl add-flow s1 table=0,priority=1,action=drop
sudo ovs-ofctl add-flow s1 table=0,priority=10,arp,action=output:"1 2 3"
#if it's coming from link 3 don't bounce the request back to avoid crowding the links
sudo ovs-ofctl add-flow s1 table=0,priority=100,in_port=3,arp,action=output:"1 2"


sudo ovs-ofctl add-flow s2 table=0,priority=1,action=drop
sudo ovs-ofctl add-flow s2 table=0,priority=10,arp,action=output:"1 2 3"
#if it's coming from link 3 don't bounce the request back to avoid crowding the links
sudo ovs-ofctl add-flow s2 table=0,priority=100,in_port=3,arp,action=output:"1 2"

#This is just an exchangepoint everything is passed
sudo ovs-ofctl add-flow s3 table=0,priority=1,action=all

#High Bandwidth Connection for everything between h1 <-> h4
#output is the thing that should be restrictive
sudo ovs-ofctl add-flow s1 table=0,priority=5,ip,nw_src=10.0.0.1,action=output:5
sudo ovs-ofctl add-flow s2 table=0,priority=5,ip,nw_src=10.0.0.4,action=output:4

#input non arp traffic should have addressing sorted out
sudo ovs-ofctl add-flow s1 table=0,priority=5,ip,nw_dst=10.0.0.1,action=output:1
sudo ovs-ofctl add-flow s2 table=0,priority=5,ip,nw_dst=10.0.0.4,action=output:2

#Low latency link between h2 <-> h3
#output is the thing that should be restrictive
sudo ovs-ofctl add-flow s1 table=0,priority=5,ip,nw_src=10.0.0.2,action=output:3
sudo ovs-ofctl add-flow s2 table=0,priority=5,ip,nw_src=10.0.0.3,action=output:3

#input non arp traffic should have addressing sorted out
sudo ovs-ofctl add-flow s1 table=0,priority=5,ip,nw_dst=10.0.0.2,action=output:2
sudo ovs-ofctl add-flow s2 table=0,priority=5,ip,nw_dst=10.0.0.3,action=output:1

#Block all ip communication between h1 and h4 for 300 seconds
sudo ovs-ofctl add-flow s1 table=0,priority=65535,hard_timeout=300,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,action=drop
sudo ovs-ofctl add-flow s2 table=0,priority=65535,hard_timeout=300,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,action=drop

sudo ovs-ofctl dump-flows s1
~                                   
