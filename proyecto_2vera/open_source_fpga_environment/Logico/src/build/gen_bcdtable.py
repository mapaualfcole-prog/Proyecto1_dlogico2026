# Genera bcdtable.txt: 1024 entradas (direccion = binario 10 bits, dato = BCD de 12 bits en hex).
# Direcciones 1000..1023 saturan en 999 (nunca se usan en el sistema).
with open("bcdtable.txt", "w") as f:
    f.write("// bcd table, HEX coded\n")
    f.write("// for 10 bit input, 12 bit output (3 digitos BCD)\n")
    for n in range(1024):
        v = min(n, 999)
        f.write("%d%d%d\n" % (v // 100, (v // 10) % 10, v % 10))
