
# Makefile con todo el flujo de trabajo para GOWIN.
# Utilizando Yosys, nextpnr, iverilog, gtkwave y openFPGALoader

# FPGA a utilizar. NO MODIFICAR.
BOARD  = tangnano9k
FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

# Nombre del proyecto
PROYECT = proyecto_2

# Fuentes de diseno
SOURCES := $(wildcard ../design/*.v ../design/*.sv)

# Fuente de simulacion
TESTBENCH = ../sim/testbench.sv

# Constraints del proyecto
CONSTRAINTS = ../constr/tangnano9k_constraints_template.cst

# Modulos principales
TOP_DESIGN = display_43
TOP_TB     = testbench

# Nombre del archivo VCD
VCD_FILE = dump.vcd


# Tabla BCD ubicada en la raiz del proyecto
ROM_SOURCE = ../../bcdtable.txt

# Copiar tabla BCD a la carpeta build en Windows
bcdtable.txt: $(ROM_SOURCE)
	powershell -NoProfile -Command "Copy-Item -LiteralPath '../../bcdtable.txt' -Destination 'bcdtable.txt' -Force"



all: synth pnr bitstream load

# Synthesis
synth: ${SOURCES} bcdtable.txt
	@echo "Ejecutando la sintesis..."
	@yosys -p "read_verilog -sv -I../design ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis_${BOARD}.log 2>&1
	@echo "COMPLETADO"

# Place and Route
pnr: ${PROYECT}.json
	@echo "Ejecutando el pnr..."
	@nextpnr-gowin --json ${PROYECT}.json --write ${PROYECT}_pnr.json --freq 27 --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr_${BOARD}.log 2>&1
	@echo "COMPLETADO"

# Generar el Bitstream
bitstream: ${PROYECT}_pnr.json
	@echo "Generando ${PROYECT}_${BOARD}.fs"
	@gowin_pack -d ${FAMILY} -o ${PROYECT}_${BOARD}.fs ${PROYECT}_pnr.json
	@echo "COMPLETADO"

# Generar VCD con Icarus Verilog
test: ${SOURCES} ${TESTBENCH} bcdtable.txt
	@iverilog -o ${PROYECT}_test.o -s ${TOP_TB} -g2005-sv -I../design ${TESTBENCH} ${SOURCES}
	@vvp ${PROYECT}_test.o

# Visualizar los diagramas de tiempo con GTKWave
wv: ${VCD_FILE}
	gtkwave ${VCD_FILE}

# Cargar el bitstream en la FPGA
load: ${PROYECT}_${BOARD}.fs
	openFPGALoader -b ${BOARD} ${PROYECT}_${BOARD}.fs

.PHONY: load wv
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json
