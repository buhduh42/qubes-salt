import re

tax_regex = re.compile(r'^(\w+)-(\w+)$')

class Taxonomy:
    def __init__(self, language, repo):
        self.language = language
        self.repo = repo

def _parse(to_parse):
    match = tax_regex.search(to_parse)
    if match is not None:
        return Taxonomy(match.group(1), match.group(2))
    return False

def language():
    tax = _parse(__grains__['id'])
    if tax is not False:
        return tax.language
    return None

def repo():
    tax = _parse(__grains__['id'])
    if tax is not False:
        return tax.repo
    return None
