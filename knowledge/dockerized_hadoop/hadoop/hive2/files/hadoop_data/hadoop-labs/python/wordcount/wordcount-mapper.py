#!/usr/bin/env python
import sys

for line in sys.stdin:
  line = line.strip()
  keys = line.split()
  for key in keys:
    print( "%s\t%d" % (key, 1) )
