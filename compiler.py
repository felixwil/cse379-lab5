import json
from sys import argv

filename = argv[1]
j = {}
with open(filename, 'r') as f:
    j = json.loads(f.read())

indent = '\n    '

def makeline(line, comment=''):
    tablen = 32
    s = indent + line
    if comment:
        comment = ' '*(tablen-(len(s)%tablen)) + '; ' + comment
    return  s + comment

ifs = 0
conditions = {
    '==':  'BNE',
    '>' :  'BLE',
    '>=':  'BLT',
    '<' :  'BGE',
    '<=':  'BGT',
}
def makeif(routine, i, line):
    global ifs
    ifs += 1
    name = f'{routine[:5]}{ifs}' 
    s = f'\n\nif_{name}:'
    r0, op, r1 = line[1].split()
    elifs = 1
    n = 2
    while 'elif' in line:
        elifname = f'elif_{name}_{i}-{elifs}'
        s += makeline(f'CMP {r0}, {r1}', 'compare regs')
        s += makeline(f'{conditions[op]} {elifname}')
        for i, w in enumerate(line[2:]):
            if w == 'elif':
                line = line[3+i:]
                break
            s += makeline(w)
        s += '\n\n' + elifname + ':'
        r0, op, r1 = line[0].split()
    s += makeline(f'CMP {r0}, {r1}', 'compare regs')
    s += makeline(f'{conditions[op]} esc{name}')
    return s + f'\n\nescapeifs_{name}:'

def getroutines():
    l = []
    for k, v in j.items():
        stack = not v or v[0] != 'nostack'
        s = f'{k}:'
        if stack:
            s += makeline('PSH {lr, r4-r11}', 'store regs')
        else:
            v = v[1:]
        for i, line in enumerate(v):
            if type(line) is str: 
                s += indent + line
            elif type(line) is list:
                if line[0] == 'if':
                    s += makeif(k, i, line)

        if stack:
            s += indent
            s += makeline('POP {lr, r0-r11}', 'restore saved regs')
            s += makeline('MOV pc, lr', 'return to source call')
        l.append(s)
    return l

for e in getroutines():
    print(e)
    