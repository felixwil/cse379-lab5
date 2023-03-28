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
operations = {
    '+' :  'ADD',
    '-' :  'SUB',
    '*' :  'MUL',
    '/' :  'DIV',
    '&' :  'AND',
    '|' :  'ORR',
    '^' :  'EOR',
}
def makeif(routine, i, line):
    global ifs
    ifs += 1
    name = f'{routine[:5]}{ifs}' 
    s = f'\nif_{name}:'
    r0, op, r1 = line[1].split()
    elifs = 1
    n = 2
    while 'elif' in line:
        elifname = f'elif_{name}_{i}-{elifs}'
        s += makeline(f'CMP {r0}, {r1}', f'b {"el" if elifs > 1 else ""}if {r0} {op} {r1}')
        s += makeline(f'{conditions[op]} {elifname}\n')
        for i, w in enumerate(line[2:]):
            if w == 'elif':
                line = line[3+i:]
                break
            s += makeline(w)
        s += '\n\n' + elifname + ':'
        r0, op, r1 = line[0].split()
    s += makeline(f'CMP {r0}, {r1}', f'b elif {r0} {op} {r1}')
    s += makeline(f'{conditions[op]} esc{name}')
    return s + f'\n\nescapeifs_{name}:'

def getroutines():
    l = []
    for k, v in j.items():
        stack = not v or v[0] != 'nostack'
        s = f'{k}:'
        if stack:
            s += makeline('PUSH {lr, r4-r11}', 'store regs')
        else:
            v = v[1:]
        for i, line in enumerate(v):
            if type(line) is str: 
                s += indent + line
            elif type(line) is list:
                s += indent
                if line[0] == 'if':
                    s += makeif(k, i, line)
                elif line[0] == 'store':
                    line[3] = line[3].replace('0x', '').replace('_', '')
                    s += makeline(f"MOV  r11, #0x{line[3][4:]}")
                    s += makeline(f"MOVT r11, #0x{line[3][:-4]}", "setting the address")
                    s += makeline(f"STR{line[1].upper()} {line[2]}, [r11]", f"storing the data from {line[2]}")
                elif line[0] == 'load':
                    line[3] = line[3].replace('0x', '').replace('_', '')
                    s += makeline(f"MOV  r11, #0x{line[3][4:]}")
                    s += makeline(f"MOVT r11, #0x{line[3][:-4]}", "setting the address")
                    s += makeline(f"LDR{line[1].upper()} {line[2]}, [r11]", f"loading the data into {line[2]}")
                elif line[1][1] == '=':
                    op = operations[line[1][0]]
                    s += makeline(f"{op} {line[0]}, {line[0]}, {line[2]}", ' '.join(line))
        if stack:
            s += indent
            s += makeline('POP {lr, r4-r11}', 'restore saved regs')
            s += makeline('MOV pc, lr', 'return to source call')
        s += '\n\n'
        l.append(s)
    return l

print('\n'.join(getroutines()))
    