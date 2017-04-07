#  _       _        _     _                  _
# (_)_ __ | |_ __ _| |__ | | ___  ___   _ __| |__
# | | '_ \| __/ _` | '_ \| |/ _ \/ __| | '__| '_ \
# | | |_) | || (_| | |_) | |  __/\__ \_| |  | |_) |
# |_| .__/ \__\__,_|_.__/|_|\___||___(_)_|  |_.__/
#   |_|
#

require 'itamae/plugin/resource/iptables'

iptables_flush 'flush' do
end

#iptables_policy 'INPUT' do
#  action :accept
#end
#
#iptables_policy 'OUTPUT' do
#  action :accept
#end
#
#iptables_policy 'FORWARD' do
#  action :accept
#end

{
  'chain ssh' => 22,
}.each do |name, port|
  iptables_rule name do
    action :create
    chain 'INPUT'
    protocol 'tcp'
    dport port
    state ['NEW']
    jump 'ACCEPT'
  end
end

iptables_save '/etc/sysconfig/iptables' do
end

execute 'restorecon /etc/sysconfig/iptables' do
end

service 'iptables' do
  action [:restart]
end

