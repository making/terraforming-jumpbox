# terraforming jumpbox

```
cp terraform.tfvars.sample terraform.tfvars
terraform plan -out plan
terraform apply plan
```

```
./ssh-jumpbox.sh
$ chomod +x ./provison.sh && ./provison.sh
```

## How to install `p-automator` on the jumpbox vm


```
pivnet login --api-token=****
mkdir platform-automation
cd platform-automation
pivnet download-product-files --product-slug='platform-automation' --release-version='4.4.3' --product-file-id=709887
tar xvf platform-automation-image-4.4.3.tgz ./rootfs/usr/bin/p-automator
sudo install rootfs/usr/bin/p-automator /usr/local/bin/
```

## How to install `pks` on the jumpbox vm


```
pivnet login --api-token=****
mkdir pks
cd pks/
pivnet download-product-files --product-slug='pivotal-container-service' --release-version='1.7.0' --product-file-id=646536
sudo install pks-linux-amd64-1.7.0-build.483 /usr/local/bin/pks
```
