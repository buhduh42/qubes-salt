import re

# because I couldn't get grains.set[val] or any incantation to persist, im going to bake targetting data into the id
# following a taxonomic scheme, currently:
# <type>-<language>-<repo>, may need to extend it further, but this should be adequate for now
# currently, type can be one of app or disp
# haven't settled on a generic scheme yet

tax_regex = re.compile(r'^(\w+)-(\w+)-(\w+)$')

# TODO will probably need to bake in constraints to type, eg app ^ disp

class Taxonomy:
    key_map = {
        'type': 1,
        'language': 2,
        'repo': 3,
    }

    def __init__(self, to_check):
        match = tax_regex.search(to_check)
        if match is None:
            return False
        self.type = match.group(Taxonomy.key_map['type'])
        self.language = match.group(Taxonomy.key_map['language'])
        self.repo = match.group(Taxonomy.key_map['repo'])
        
    def get(self, key):
        if key not in Taxonomy.key_map:
            raise Exception("taxonomy type not recognized '%s'" % key)
        return getattr(self, key)


def get(key):
    tax = Taxonomy(__grains__['id'])
    if tax is not False:
        return tax.get(key)
    return None

def type():
    tax = Taxonomy(__grains__['id'])
    if tax is False:
        return None
    return tax.get('type')

def language():
    tax = Taxonomy(__grains__['id'])
    if tax is False:
        return None
    return tax.get('language')

def repo():
    tax = Taxonomy(__grains__['id'])
    if tax is False:
        return None
    return tax.get('repo')
