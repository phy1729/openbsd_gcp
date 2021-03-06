1) If https://github.com/double-p/packer-builder-openbsd-vmm/pull/16 is still open
    1) `git clone https://github.com/phy1729/packer-builder-openbsd-vmm`
    1) `cd packer-builder-openbsd-vmm`
    1) `git checkout fix-artifact-files`
    1) `make install`
    1) Once the PR is merged and the port is updated, you can `rm ~/.packer.d/plugins/packer-builder-openbsd-vmm` (or `make uninstall` which does about the same thing).
1) Run `ansible-playbook packer.yml -CD` to ensure the are will be acceptable then run `ansible-playbook packer.yml -D` to make the changes.
    There are a few variables to customize the built image.
    * hostname: (default `openbsd`) Hostname for the image.
    * `root_password`: (default `*************`) Password for root (plaintext or encrypted). As this will be used with [autoinstall(8)](https://man.openbsd.org/autoinstall.8), 13 `*` disables password logins.
    * `username`: (default username of the user running ansible) Username of the user to setup during install. Blank to disable.
    * `user_password`: (default `*************`) Password for the user (plaintext or encrypted). As this will be used with [autoinstall(8)](https://man.openbsd.org/autoinstall.8), 13 `*` disables password logins.
    * `user_pubkey`: (default: contents of `~/.ssh/ed_25519.pub`) The public key for the user.
    * `timezone`: (default: `UTC`) Timezone for the image.
1) Allow the VM to talk to the host. Since the interface is created on VM start and destroyed after stop, add `pass quick on tap` to pf.conf and reload as you can't skip on the specific interface.
1) Setup an account.json credentials file.
    1) [Create a service account](https://console.cloud.google.com/iam-admin/serviceaccounts)
    1) Grant at least the following permissions (if you want to grant just these permissions, you'll need to create a custom role).
        * compute.globalOperations.get
        * compute.images.create
        * storage.objects.create
        * storage.objects.delete
        * storage.objects.get
    1) Under actions, Manage keys and Create a new key.
    1) Save it as account.json.
1) Create var file defining `project_id` and `bucket`.
    ```
    project_id = "example"
    bucket     = "example"
    ```
1) Run `packer build -var-file openbsd.pkrvars.hcl openbsd.pkr.hcl`.
    1) Watch the installation progress with `tail -f disk.log`.
    1) When the congratulations message prints, stop the vm with `doas vmctl stop disk`.
1) Put your system back to normal.
    1) Remove packer and packer-vmm (possibly with `make uninstall` as mentioned in step 1).
    1) Remove /etc/hostname.bridge0 and /etc/vm.conf (or set those back to their prior state).
    1) Reset pf.conf to its prior state.
    1) Disable vmd.
    1) Remove the GCP service account.
