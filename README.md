# puppet-elasticsearch

This puppet module was written to install, configure, and start and elastic search node or cluster

I have built an RPM package for elasticsearch and as such, this module uses the package provider to install the actual
sever binaries

# Usage

This module will support all the various elasticsearch node types: client, master, data, default and tribe.

# Client
 elasticsearch::node { 'lb_logs' :<br/>
   node_type     => 'client',<br/>
   cluster_name  => 'log_cluster_01',<br/>
   cluster_nodes => [ 'node1.example.tld', 'node2.example.tld', 'node3.example.tld' ],<br/>
 }<br/>

# Default
 elasticsearch::node { 'log_cluster' :<br/>
   node_type     => 'default',<br/>
   heap_size     => '4G',<br/>
   cluster_nodes => [ 'node1.example.tld', 'node2.example.tld', 'node3.example.tld' ],<br/>
   cluster_name  => 'log_cluster_01',<br/>
   client_port   => '9200',<br/>
   peer_port     => '9300',<br/>
   mlockall      => true,<br/>
   use_iptables  => 'yes',<br/>
 }<br/>

The 'use_iptables' flag causes the module to call my puppet-iptables module and open the default client and sync ports (9200 & 9300).

