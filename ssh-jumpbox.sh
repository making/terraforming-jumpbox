#!/bin/bash
terraform output jumpbox_ssh_private_key > jumpbox.pem
chmod 600 jumpbox.pem

ssh -o "StrictHostKeyChecking=no" ubuntu@$(terraform output jumpbox_public_ip) -i $(pwd)/jumpbox.pem
