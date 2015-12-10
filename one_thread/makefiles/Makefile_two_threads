# make          <- runs simv (after compiling simv if needed)
# make simv     <- compile simv if needed (but do not run)
# make syn      <- runs syn_simv (after synthesizing if needed then 
#                                 compiling synsimv if needed)
# make clean    <- remove files created during compilations (but not synthesis)
# make nuke     <- remove all files created during compilation and synthesis
#
# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be 
# similar to the information in those scripts but that seems hard to avoid.
#

VCS = SW_VCS=2015.09 vcs -sverilog +vc -Mupdate -line -full64 +define+
VISFLAGS = -lncurses
all:    simv
	./simv | tee program.out

##### 
# Modify starting here
#####

TESTBENCH = 	sys_defs.vh	\
				test_bench/twothreads_testbench_pr.v	\
				test_bench/mem.v		\
				test_bench/pipe_print.c
SIMFILES = 	verilog/cdb.v	\
			verilog/cdb_one_entry.v	\
			verilog/ex_stage.v	\
			verilog/id_stage.v	\
			verilog/if_stage.v	\
			verilog/mult_stage.v	\
			verilog/pc.v	\
			verilog/pipe_mult.v	\
			verilog/prf.v	\
			verilog/prf_one_entry.v	\
			verilog/priority_selector.v	\
			verilog/processor.v	\
			verilog/rat.v	\
			verilog/rob.v	\
			verilog/rob_one_entry.v	\
			verilog/rrat.v	\
			verilog/rs.v	\
			verilog/rs_one_entry.v	\
			verilog/lq_one_entry.v	\
			verilog/sq_one_entry.v	\
			verilog/lsq.v	\
			 

SYNFILES = processor.vg 
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

# For visual debugger
VISTESTBENCH = $(TESTBENCH:twothreads_testbench_pr.v=visual_testbench_pr.v) \
		test_bench/visual_c_hooks.c

processor.vg:	$(SIMFILES) tcl_files/processor.tcl 
	dc_shell-t -f tcl_files/processor.tcl | tee synth.out

#####
# Should be no need to modify after here
#####

dve:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) +memcbk $(TESTBENCH) $(SIMFILES) -o dve -R -gui
	
dve_syn:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) +define+SYNTH_TEST -o syn_simv -R -gui
	
# For visual debugger
vis_simv:	$(SIMFILES) $(VISTESTBENCH)
	$(VCS) $(VISFLAGS) $(VISTESTBENCH) $(SIMFILES) +define+SYNTH_TEST -o  vis_simv 
	./vis_simv

simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES)	-o simv

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) +define+SYNTH_TEST -o  syn_simv

syn:	syn_simv
	./syn_simv | tee syn_program.out
	



clean:
	rm -rvf simv *.daidir csrc vcs.key program.out \
	  syn_simv syn_simv.daidir syn_program.out \
          dve *.vpd *.vcd *.dump ucli.key 

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out DVEfiles/ *.ddc *.res *_svsim.sv default.svf *.vdb *.syn *.mr *.pvl
