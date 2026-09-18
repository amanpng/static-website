[web]
%{ for instance in web_servers ~}
${instance.name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=${ssh_private_key_path}
