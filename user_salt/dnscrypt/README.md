## Without top

makesure requisite templates/vms exist and are in the appropriate state(qvm-* commands, hence dom0)
```
qubesctl --targets=dom0 state.apply dnscrypt.templates
```
install requisite software on template
```
qubesctl --skip-dom0 --targets=f39-m-dns state.apply dnscrypt.templates
```
prepare disposable template for dnscrypt-proxy, eg setting up various /rw stuff
```
qubesctl --skip-dom0 --targets=f39-m-dns-dvm state.apply dnscrypt.disp_vm
```
