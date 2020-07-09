#!/bin/bash
export AWS_ACCESS_KEY_ID='AKIAY7ZMJG47VS4KIGTN'
export AWS_SECRET_ACCESS_KEY='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'
export ANSIBLE_HOSTS=/home/ubuntu/mediawiki/ansible-playbook/ec2.py
EC2_INI_PATH=/home/ubuntu/mediawiki/ansible-playbook/ec2.ini
ssh-agent bash 
ssh-add mediawiki_key.pem 
./ec2.py --list --refresh-cache

ansible-playbook site.yml -i ec2.py -vv --private-key mediawiki_key.pem -i ec2.py --limit "tag_group_db" --tags "install_db" --ask-vault-pass -u ec2-user
ansible-playbook site.yml -i ec2.py -vv --private-key mediawiki_key.pem -i ec2.py --limit "tag_group_web" --tags "install_web" --ask-vault-pass -u ec2-user
ansible-playbook site.yml -i ec2.py -vv --private-key mediawiki_key.pem -i ec2.py --limit "tag_group_grafana" --tags "install_grafana" --ask-vault-pass -u ubuntu