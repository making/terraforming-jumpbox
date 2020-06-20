# terraforming jumpbox

```
cp terraform.tfvars.sample terraform.tfvars
terraform plan -out plan
terraform apply plan
```

```
./ssh-jumpbox.sh
$ ./provison.sh
```