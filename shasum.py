# https://stackoverflow.com/questions/22058048/hashing-a-file-in-python

import hashlib

def calculate_shasum(filename):
  """Calculate SHA256 hash of a file."""
  sha256 = hashlib.sha256()
  with open(filename, 'rb') as f:
    while True:
      data = f.read()
      if not data:
        break
      sha256.update(data)
  return sha256.hexdigest()

def read_shasum(filename, platform='-x86_64-linux-gnu.tar.gz'):
  """Read appropriate shasum from an .asc file."""
  with open(filename) as f:
    for line in f:
      if platform in line:
        return line.split()[0]
  return None

def verify_shasum(filename, asc_filename):
  got = calculate_shasum(filename)
  want = read_shasum(asc_filename)
  fail_txt = f'SHA does not match! Wanted {want} but got {got}.'
  assert want == got, fail_txt

verify_shasum('/tmp/litecoin.tar.gz', '/tmp/litecoin-signatures.asc')