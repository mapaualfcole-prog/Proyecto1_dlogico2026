#Makefile con todo el flujo de trabajo para GOWIN. Utilizando Yosys, nextpnr, iverilog, gtkwave y openFPGALoader

BOARD  = tangnano9k
FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

PROYECT = Logico

#Todas las fuentes .v o .sv que estan en design
SOURCES := $(wildcard ../design/*.v ../design/*.sv)

#Fuente de simulacion (se puede cambiar desde la linea de comandos:
#make test TESTBENCH=../sim/tb_sub_comp2.sv TOP_TB=tb_sub_comp2)
TESTBENCH = ../sim/tb_restador.sv

CONSTRAINTS = ../constr/Pines.cst

TOP_DESIGN = restador
TOP_TB = tb_restador

VCD_FILE = tb_restador.vcd

all: synth pnr bitstream load

synth: ${SOURCES}
	@echo "Ejecutando la sintesis..."
	@yosys -p "read_verilog -sv ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis_${BOARD}.log 2>&1
	@echo "COMPLETADO"

pnr: ${PROYECT}.json
	@echo "Ejecutando el pnr..."
	@nextpnr-gowin --json ${PROYECT}.json --write ${PROYECT}_pnr.json --freq 27 --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr_${BOARD}.log 2>&1
	@echo "COMPLETADO"

bitstream: ${PROYECT}_pnr.json
	@echo "Generando ${PROYECT}_${BOARD}.fs"
	@gowin_pack -d ${FAMILY} -o ${PROYECT}_${BOARD}.fs ${PROYECT}_pnr.json
	@echo "COMPLETADO"

#Simulacion con icarus verilog (-g2012, igual que EDA Playground)
test: ${SOURCES} ${TESTBENCH}
	@iverilog -o ${PROYECT}_test.o -s ${TOP_TB} -g2012 ${TESTBENCH} ${SOURCES}
	@vvp ${PROYECT}_test.o

wv: ${VCD_FILE}
	gtkwave ${VCD_FILE}

load: ${PROYECT}_${BOARD}.fs
	openFPGALoader -b ${BOARD} ${PROYECT}_${BOARD}.fs

.PHONY: all synth pnr bitstream load test wv
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json
