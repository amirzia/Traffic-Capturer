
# Clean netspaces
sudo ./clean.sh


DB_DIR="./dbs/"
PCAP_DIR="./pcaps/"

if [ ! -d $DB_DIR ]; then
    mkdir $DB_DIR
fi

if [ ! -d $PCAP_DIR ]; then
	mkdir $PCAP_DIR
fi

# Flush forward rules.
sudo iptables -P FORWARD DROP
sudo iptables -F FORWARD

# Flush nat rules.
sudo iptables -t nat -F


# Start crawl
sudo ./capture.sh wikipedia ns1 veth1 vpeer1 10.200.1.1 10.200.1.2
sudo ./capture.sh digikala ns2 veth2 vpeer2 11.200.1.1 11.200.1.2
sudo ./capture.sh github ns4 veth4 vpeer4 13.200.1.1 13.200.1.2
sudo ./capture.sh stackoverflow ns5 veth5 vpeer5 14.200.1.1 14.200.1.2
sudo ./capture.sh divar ns6 veth6 vpeer6 15.200.1.1 15.200.1.2
sudo ./capture.sh sharif ns8 veth8 vpeer8 17.200.1.1 17.200.1.2
sudo ./capture.sh zoomit ns9 veth9 vpeer9 18.200.1.1 18.200.1.2
sudo ./capture.sh asriran ns10 veth10 vpeer10 19.200.1.1 19.200.1.2
