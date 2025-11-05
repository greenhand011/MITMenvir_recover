# MITMenvir_recover
用iptables进行MITM测试后
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A PREROUTING -p tcp -s 192.168.12.80 -d 198.18.1.49 -j DNAT --to 192.168.12.1:8084
iptables -t nat -L
mitmweb --rawtcp -p 8084 --mode transparent --showhost
操作完以上命令后恢复环境
