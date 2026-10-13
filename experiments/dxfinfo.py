#!/usr/bin/env python3
"""Summarize a DXF: sections, NOD entries, ACAD_TABLESTYLE / ACAD_MLEADERSTYLE
dictionaries, CLASSES, object types in OBJECTS. Usage: dxfinfo.py file.dxf"""
import sys, collections

def pairs(path):
    with open(path, 'rb') as f:
        lines = f.read().decode('latin-1').splitlines()
    for i in range(0, len(lines) - 1, 2):
        yield lines[i].strip(), lines[i + 1].rstrip('\r')

def objects(path):
    """yield (section, [(code,value),...]) for every 0-started record"""
    sec = None; cur = None; expect_name = False
    for c, v in pairs(path):
        if c == '0':
            if cur: yield sec, cur
            cur = [(0, v.strip())]
            if v.strip() == 'ENDSEC': sec = None; cur = None
            continue
        if cur is not None and cur[0][1] == 'SECTION' and c == '2':
            sec = v.strip(); cur = None; continue
        if cur is not None:
            try: cur.append((int(c), v))
            except ValueError: cur.append((-9999, v))
    if cur: yield sec, cur

def main(path):
    objs = list(objects(path))
    byh = {}
    for sec, o in objs:
        for c, v in o:
            if c in (5, 105):
                byh[v.strip().upper()] = (sec, o); break
    secs = collections.Counter(s for s, _ in objs)
    print('sections:', dict(secs))
    hdr = [o for s, o in objs if s == 'HEADER']
    classes = [dict((c, v) for c, v in o)[1] for s, o in objs if s == 'CLASSES']
    print('classes:', classes)
    types = collections.Counter(o[0][1] for s, o in objs if s == 'OBJECTS')
    print('OBJECTS types:', dict(types))
    nod = None
    for s, o in objs:
        if s == 'OBJECTS' and o[0][1] == 'DICTIONARY':
            nod = o; break
    def dent(o):
        res = []; key = None
        for c, v in o:
            if c == 3: key = v
            elif c in (350, 360) and key is not None: res.append((key, v.strip())); key = None
        return res
    if nod:
        print('NOD entries:')
        for k, h in dent(nod):
            print('   ', k, h, byh.get(h.upper(), (None, [(0, '?')]))[1][0][1])
            if k in ('ACAD_TABLESTYLE', 'ACAD_MLEADERSTYLE'):
                d = byh.get(h.upper())
                if d:
                    for k2, h2 in dent(d[1]):
                        print('        ', k2, h2, byh.get(h2.upper(), (None, [(0, '?')]))[1][0][1])

if __name__ == '__main__':
    main(sys.argv[1])
