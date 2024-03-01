## Initial Setup
Clone to any qube with git.
**Highly Recommended**
copy repo to development qube with no network access:
Ensure user_salt is enabled by following [this](https://forum.qubes-os.org/t/qubes-salt-beginners-guide/20126)
In salt development qube, bundle states into tar ball
```
#salt development qube
#see manage_states.sh --help
<path_to_repo>/package.sh hashes
<path_to_repo>/package.sh tar
```
In dom0, run:
```
#dom0 as root
qvm-run --pass-io <salt source, either git repo or copied repo vm> <path to repo> "cat manage_states.sh" > /srv
cd srv
#see package.sh --help
tar_hash=$(./manage_states.sh get-hash)
#youre encouraged to manaually inspcet the tar hashes on the development machine
./manage_states.sh --tar-hash ${tar_hash}
#might need to sync salt....
qubesctl --skip-dom0 --targets=<qube names to target> saltutil.sync_all saltenv=user
```

## Targeting(Taxonomy)
Wasn't able to permanently set grains on minions with adding files to the machines, I chose not to do this.
Ended up rolling a taxonomic system, see [top](user_salt/top.sls) and/or [taxonomy](user_salt/_modules/taxonomy.py)
For an explanation of my targeting gimmick
