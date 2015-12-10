# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Dec 9 00:15:37 2015
# Designs open: 1
#   Sim: dve
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: _vcs_unit__497791245
#   Wave.1: 157 signals
#   Group count = 2
#   Group Group1 signal count = 44
#   Group Group2 signal count = 157
# End_DVE_Session_Save_Info

# DVE version: K-2015.09_Full64
# DVE build date: Aug 25 2015 21:36:02


#<Session mode="Full" path="/home/golifan/Downloads/EECS470/project4/group7f15/two_threads/lsq.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{29 65} {2528 1418}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 150]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 150
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 149} {height 1090} {dock_state left} {dock_on_new_line true} {child_hier_colhier 192} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 387]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 387
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 1090
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 386} {height 1090} {dock_state left} {dock_on_new_line true} {child_data_colvariable 264} {child_data_colvalue 64} {child_data_coltype 111} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 175]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 2500
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 175
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 2499} {height 174} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{73 68} {2558 1413}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 721} {child_wave_right 1759} {child_wave_colname 358} {child_wave_colvalue 359} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{ +vc +define+ +memcbk -ucligui}}
gui_set_env SIMSETUP::SIMEXE {dve}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {dve}] } {
gui_sim_run Ucli -exe dve -args { +vc +define+ +memcbk -ucligui} -dir ../two_threads -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 100ps
gui_set_time_units 100ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {testbench.processor_0.pc}


set _session_group_3 Group1
gui_sg_create "$_session_group_3"
set Group1 "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { testbench.processor_0.pc.clock testbench.processor_0.pc.reset testbench.processor_0.pc.thread1_branch_is_taken testbench.processor_0.pc.thread2_branch_is_taken testbench.processor_0.pc.thread1_target_pc testbench.processor_0.pc.thread2_target_pc testbench.processor_0.pc.rs_stall testbench.processor_0.pc.rob1_stall testbench.processor_0.pc.rob2_stall testbench.processor_0.pc.rat_stall testbench.processor_0.pc.thread1_structure_hazard_stall testbench.processor_0.pc.thread2_structure_hazard_stall testbench.processor_0.pc.Icache2proc_data testbench.processor_0.pc.Icache2proc_tag testbench.processor_0.pc.Icache2proc_response testbench.processor_0.pc.Icache_hit testbench.processor_0.pc.is_two_threads testbench.processor_0.pc.proc2Icache_addr testbench.processor_0.pc.proc2Icache_command testbench.processor_0.pc.next_PC_out testbench.processor_0.pc.inst1_out testbench.processor_0.pc.inst2_out testbench.processor_0.pc.inst1_is_valid testbench.processor_0.pc.inst2_is_valid testbench.processor_0.pc.thread1_is_available testbench.processor_0.pc.proc2Imem_addr_previous testbench.processor_0.pc.is_next_thread1 testbench.processor_0.pc.PC_reg1 testbench.processor_0.pc.PC_reg2 testbench.processor_0.pc.next_PC1 testbench.processor_0.pc.next_PC2 testbench.processor_0.pc.current_inst1 testbench.processor_0.pc.next_current_inst1 testbench.processor_0.pc.current_inst2 testbench.processor_0.pc.next_current_inst2 testbench.processor_0.pc.pc1_stall testbench.processor_0.pc.pc2_stall testbench.processor_0.pc.next_t1 testbench.processor_0.pc.thread1_is_done testbench.processor_0.pc.next_t1_done testbench.processor_0.pc.thread2_is_done testbench.processor_0.pc.next_t2_done testbench.processor_0.pc.next_command testbench.processor_0.pc.start }

set _session_group_4 Group2
gui_sg_create "$_session_group_4"
set Group2 "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { testbench.processor_0.lsq1.clock testbench.processor_0.lsq1.reset testbench.processor_0.lsq1.lsq_cdb1_in testbench.processor_0.lsq1.lsq_cdb1_tag testbench.processor_0.lsq1.lsq_cdb1_valid testbench.processor_0.lsq1.lsq_cdb2_in testbench.processor_0.lsq1.lsq_cdb2_tag testbench.processor_0.lsq1.lsq_cdb2_valid testbench.processor_0.lsq1.inst1_valid testbench.processor_0.lsq1.inst1_op_type testbench.processor_0.lsq1.inst1_pc testbench.processor_0.lsq1.inst1_in testbench.processor_0.lsq1.lsq_rega_in1 testbench.processor_0.lsq1.lsq_rega_valid1 testbench.processor_0.lsq1.lsq_opa_in1 testbench.processor_0.lsq1.lsq_opb_in1 testbench.processor_0.lsq1.lsq_opb_valid1 testbench.processor_0.lsq1.lsq_rob_idx_in1 testbench.processor_0.lsq1.dest_reg_idx1 testbench.processor_0.lsq1.inst2_valid testbench.processor_0.lsq1.inst2_op_type testbench.processor_0.lsq1.inst2_pc testbench.processor_0.lsq1.inst2_in testbench.processor_0.lsq1.lsq_rega_in2 testbench.processor_0.lsq1.lsq_rega_valid2 testbench.processor_0.lsq1.lsq_opa_in2 testbench.processor_0.lsq1.lsq_opb_in2 testbench.processor_0.lsq1.lsq_opb_valid2 testbench.processor_0.lsq1.lsq_rob_idx_in2 testbench.processor_0.lsq1.dest_reg_idx2 testbench.processor_0.lsq1.mem_data_in testbench.processor_0.lsq1.mem_response_in testbench.processor_0.lsq1.mem_tag_in testbench.processor_0.lsq1.cache_hit testbench.processor_0.lsq1.t1_head testbench.processor_0.lsq1.t2_head testbench.processor_0.lsq1.thread1_mispredict testbench.processor_0.lsq1.thread2_mispredict testbench.processor_0.lsq1.cdb_dest_tag1 testbench.processor_0.lsq1.cdb_result_out1 testbench.processor_0.lsq1.cdb_result_is_valid1 testbench.processor_0.lsq1.cdb_rob_idx1 testbench.processor_0.lsq1.cdb_dest_tag2 testbench.processor_0.lsq1.cdb_result_out2 testbench.processor_0.lsq1.cdb_result_is_valid2 testbench.processor_0.lsq1.cdb_rob_idx2 testbench.processor_0.lsq1.mem_data_out testbench.processor_0.lsq1.mem_address_out testbench.processor_0.lsq1.lsq2Dcache_command testbench.processor_0.lsq1.lsq_is_full testbench.processor_0.lsq1.inst1_opb testbench.processor_0.lsq1.inst1_opb_valid testbench.processor_0.lsq1.inst2_opb testbench.processor_0.lsq1.inst2_opb_valid testbench.processor_0.lsq1.inst1_rega testbench.processor_0.lsq1.inst1_rega_valid testbench.processor_0.lsq1.inst2_rega testbench.processor_0.lsq1.inst2_rega_valid testbench.processor_0.lsq1.lq_mem_in1 testbench.processor_0.lsq1.lq_mem_in2 testbench.processor_0.lsq1.lq1_mem_in_temp1 testbench.processor_0.lsq1.lq1_mem_in_temp2 testbench.processor_0.lsq1.lq2_mem_in_temp1 testbench.processor_0.lsq1.lq2_mem_in_temp2 testbench.processor_0.lsq1.lq1_mem_in_temp1_1 testbench.processor_0.lsq1.lq1_mem_in_temp2_2 testbench.processor_0.lsq1.lq2_mem_in_temp1_1 testbench.processor_0.lsq1.lq2_mem_in_temp2_2 testbench.processor_0.lsq1.lq1_request2mem testbench.processor_0.lsq1.lq2_request2mem testbench.processor_0.lsq1.lq1_requested testbench.processor_0.lsq1.lq2_requested testbench.processor_0.lsq1.lq1_clean testbench.processor_0.lsq1.lq2_clean testbench.processor_0.lsq1.lq1_free_en testbench.processor_0.lsq1.lq2_free_en testbench.processor_0.lsq1.lq1_is_ready testbench.processor_0.lsq1.lq2_is_ready testbench.processor_0.lsq1.lq1_mem_data_in_valid testbench.processor_0.lsq1.lq2_mem_data_in_valid testbench.processor_0.lsq1.lq1_is_available testbench.processor_0.lsq1.lq2_is_available testbench.processor_0.lsq1.lq1_addr_valid testbench.processor_0.lsq1.lq2_addr_valid testbench.processor_0.lsq1.lq1_opa testbench.processor_0.lsq1.lq1_opb testbench.processor_0.lsq1.lq2_opa testbench.processor_0.lsq1.lq2_opb testbench.processor_0.lsq1.lq1_rob_idx testbench.processor_0.lsq1.lq2_rob_idx testbench.processor_0.lsq1.lq1_pc testbench.processor_0.lsq1.lq2_pc testbench.processor_0.lsq1.lq1_dest_tag testbench.processor_0.lsq1.lq2_dest_tag testbench.processor_0.lsq1.lq1_mem_value testbench.processor_0.lsq1.lq2_mem_value testbench.processor_0.lsq1.lq1_mem_value_valid testbench.processor_0.lsq1.lq2_mem_value_valid testbench.processor_0.lsq1.sq_mem_in1 }
gui_sg_addsignal -group "$_session_group_4" { testbench.processor_0.lsq1.sq_mem_in2 testbench.processor_0.lsq1.sq1_clean testbench.processor_0.lsq1.sq2_clean testbench.processor_0.lsq1.sq1_free_en testbench.processor_0.lsq1.sq2_free_en testbench.processor_0.lsq1.sq1_is_ready testbench.processor_0.lsq1.sq2_is_ready testbench.processor_0.lsq1.sq_head1 testbench.processor_0.lsq1.n_sq_head1 testbench.processor_0.lsq1.sq_head2 testbench.processor_0.lsq1.n_sq_head2 testbench.processor_0.lsq1.sq_tail1 testbench.processor_0.lsq1.n_sq_tail1 testbench.processor_0.lsq1.sq_tail2 testbench.processor_0.lsq1.n_sq_tail2 testbench.processor_0.lsq1.sq1_is_available testbench.processor_0.lsq1.sq2_is_available testbench.processor_0.lsq1.sq1_opa testbench.processor_0.lsq1.sq1_opb testbench.processor_0.lsq1.sq2_opa testbench.processor_0.lsq1.sq2_opb testbench.processor_0.lsq1.sq1_rob_idx testbench.processor_0.lsq1.sq2_rob_idx testbench.processor_0.lsq1.sq1_pc testbench.processor_0.lsq1.sq2_pc testbench.processor_0.lsq1.sq1_store_data testbench.processor_0.lsq1.sq2_store_data testbench.processor_0.lsq1.sq1_dest_tag testbench.processor_0.lsq1.sq2_dest_tag testbench.processor_0.lsq1.inst1_type testbench.processor_0.lsq1.inst2_type testbench.processor_0.lsq1.inst1_is_lq1 testbench.processor_0.lsq1.inst1_is_lq2 testbench.processor_0.lsq1.inst1_is_sq1 testbench.processor_0.lsq1.inst1_is_sq2 testbench.processor_0.lsq1.inst2_is_lq1 testbench.processor_0.lsq1.inst2_is_lq2 testbench.processor_0.lsq1.inst2_is_sq1 testbench.processor_0.lsq1.inst2_is_sq2 testbench.processor_0.lsq1.out1_is_sq1 testbench.processor_0.lsq1.out1_is_sq2 testbench.processor_0.lsq1.out2_is_sq1 testbench.processor_0.lsq1.out2_is_sq2 testbench.processor_0.lsq1.current_mem_inst testbench.processor_0.lsq1.tag_table testbench.processor_0.lsq1.tag_valid testbench.processor_0.lsq1.lda1_dest_tag testbench.processor_0.lsq1.lda1_result testbench.processor_0.lsq1.lda1_valid testbench.processor_0.lsq1.lda1_rob_idx testbench.processor_0.lsq1.lda2_dest_tag testbench.processor_0.lsq1.lda2_result testbench.processor_0.lsq1.lda2_valid testbench.processor_0.lsq1.lda2_rob_idx testbench.processor_0.lsq1.next_mem_valid testbench.processor_0.lsq1.next_mem_inst testbench.processor_0.lsq1.next_next_mem_valid testbench.processor_0.lsq1.next_next_mem_inst }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1501070



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} testbench}
catch {gui_list_expand -id ${Hier.1} testbench.processor_0}
catch {gui_list_select -id ${Hier.1} {testbench.processor_0.lsq1}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {testbench.processor_0.lsq1}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {testbench.processor_0.lsq1.lsq_rob_idx_in1 testbench.processor_0.lsq1.inst2_valid testbench.processor_0.lsq1.lq1_mem_in_temp1_1 testbench.processor_0.lsq1.lsq_rob_idx_in2 testbench.processor_0.lsq1.inst2_in testbench.processor_0.lsq1.inst2_opb testbench.processor_0.lsq1.sq2_dest_tag testbench.processor_0.lsq1.lq1_addr_valid testbench.processor_0.lsq1.t1_head testbench.processor_0.lsq1.inst1_rega_valid testbench.processor_0.lsq1.inst2_rega testbench.processor_0.lsq1.inst2_pc testbench.processor_0.lsq1.mem_data_in testbench.processor_0.lsq1.sq2_pc testbench.processor_0.lsq1.sq1_free_en testbench.processor_0.lsq1.sq2_clean testbench.processor_0.lsq1.lq2_pc testbench.processor_0.lsq1.sq2_rob_idx testbench.processor_0.lsq1.sq_mem_in1 testbench.processor_0.lsq1.sq_mem_in2 testbench.processor_0.lsq1.inst2_is_sq1 testbench.processor_0.lsq1.inst2_is_sq2 testbench.processor_0.lsq1.out1_is_sq1 testbench.processor_0.lsq1.lq1_clean testbench.processor_0.lsq1.next_next_mem_inst testbench.processor_0.lsq1.out1_is_sq2 testbench.processor_0.lsq1.lq2_requested testbench.processor_0.lsq1.dest_reg_idx1 testbench.processor_0.lsq1.dest_reg_idx2 testbench.processor_0.lsq1.lsq_cdb1_in testbench.processor_0.lsq1.sq_tail1 testbench.processor_0.lsq1.sq1_opa testbench.processor_0.lsq1.sq_tail2 testbench.processor_0.lsq1.sq1_opb testbench.processor_0.lsq1.sq1_is_ready testbench.processor_0.lsq1.tag_table testbench.processor_0.lsq1.lq1_mem_in_temp1 testbench.processor_0.lsq1.lq1_mem_in_temp2 testbench.processor_0.lsq1.clock testbench.processor_0.lsq1.cdb_dest_tag1 testbench.processor_0.lsq1.lq1_dest_tag testbench.processor_0.lsq1.cdb_dest_tag2 testbench.processor_0.lsq1.sq2_store_data testbench.processor_0.lsq1.lq1_free_en testbench.processor_0.lsq1.reset testbench.processor_0.lsq1.lq2_mem_in_temp1 testbench.processor_0.lsq1.sq2_is_available testbench.processor_0.lsq1.lq2_mem_in_temp2 testbench.processor_0.lsq1.lda1_rob_idx testbench.processor_0.lsq1.current_mem_inst testbench.processor_0.lsq1.inst1_type testbench.processor_0.lsq1.lsq_opb_valid1 testbench.processor_0.lsq1.lsq_opb_valid2 testbench.processor_0.lsq1.lq2_mem_value testbench.processor_0.lsq1.lq2_rob_idx testbench.processor_0.lsq1.sq2_opa testbench.processor_0.lsq1.sq2_opb testbench.processor_0.lsq1.inst2_is_lq1 testbench.processor_0.lsq1.inst2_is_lq2 testbench.processor_0.lsq1.lq_mem_in1 testbench.processor_0.lsq1.lsq_rega_in1 testbench.processor_0.lsq1.lq_mem_in2 testbench.processor_0.lsq1.lsq_rega_in2 testbench.processor_0.lsq1.inst1_valid testbench.processor_0.lsq1.sq2_is_ready testbench.processor_0.lsq1.lsq_is_full testbench.processor_0.lsq1.lq2_dest_tag testbench.processor_0.lsq1.lq1_request2mem testbench.processor_0.lsq1.lq1_mem_value_valid testbench.processor_0.lsq1.thread1_mispredict testbench.processor_0.lsq1.lq2_mem_value_valid testbench.processor_0.lsq1.mem_response_in testbench.processor_0.lsq1.inst1_is_sq1 testbench.processor_0.lsq1.sq2_free_en testbench.processor_0.lsq1.inst1_is_sq2 testbench.processor_0.lsq1.mem_tag_in testbench.processor_0.lsq1.sq1_clean testbench.processor_0.lsq1.lsq_cdb1_tag testbench.processor_0.lsq1.mem_data_out testbench.processor_0.lsq1.lq1_requested testbench.processor_0.lsq1.inst1_op_type testbench.processor_0.lsq1.lsq_rega_valid1 testbench.processor_0.lsq1.lda2_valid testbench.processor_0.lsq1.lsq_rega_valid2 testbench.processor_0.lsq1.inst1_rega testbench.processor_0.lsq1.n_sq_tail1 testbench.processor_0.lsq1.n_sq_tail2 testbench.processor_0.lsq1.sq_head1 testbench.processor_0.lsq1.sq_head2 testbench.processor_0.lsq1.lq1_opa testbench.processor_0.lsq1.lsq_opa_in1 testbench.processor_0.lsq1.lq1_opb testbench.processor_0.lsq1.lsq_opa_in2 testbench.processor_0.lsq1.lq2_addr_valid testbench.processor_0.lsq1.lq1_is_ready testbench.processor_0.lsq1.lsq_cdb2_tag testbench.processor_0.lsq1.lsq_cdb2_in testbench.processor_0.lsq1.cdb_rob_idx1 testbench.processor_0.lsq1.lda1_dest_tag testbench.processor_0.lsq1.cdb_rob_idx2 testbench.processor_0.lsq1.lq2_free_en testbench.processor_0.lsq1.inst1_is_lq1 testbench.processor_0.lsq1.inst2_rega_valid testbench.processor_0.lsq1.inst2_opb_valid testbench.processor_0.lsq1.inst1_is_lq2 testbench.processor_0.lsq1.lq1_mem_value testbench.processor_0.lsq1.lq2_request2mem testbench.processor_0.lsq1.lda2_rob_idx testbench.processor_0.lsq1.lda2_result testbench.processor_0.lsq1.lq2_opa testbench.processor_0.lsq1.t2_head testbench.processor_0.lsq1.lsq_opb_in1 testbench.processor_0.lsq1.lq2_opb testbench.processor_0.lsq1.lsq2Dcache_command testbench.processor_0.lsq1.lsq_opb_in2 testbench.processor_0.lsq1.lsq_cdb2_valid testbench.processor_0.lsq1.inst1_in testbench.processor_0.lsq1.lq2_is_ready testbench.processor_0.lsq1.cdb_result_out1 testbench.processor_0.lsq1.cdb_result_out2 testbench.processor_0.lsq1.lda2_dest_tag testbench.processor_0.lsq1.tag_valid testbench.processor_0.lsq1.inst1_pc testbench.processor_0.lsq1.lq1_mem_data_in_valid testbench.processor_0.lsq1.sq1_store_data testbench.processor_0.lsq1.lq2_mem_in_temp2_2 testbench.processor_0.lsq1.cdb_result_is_valid1 testbench.processor_0.lsq1.cdb_result_is_valid2 testbench.processor_0.lsq1.sq1_pc testbench.processor_0.lsq1.lq2_mem_in_temp1_1 testbench.processor_0.lsq1.mem_address_out testbench.processor_0.lsq1.lq1_pc testbench.processor_0.lsq1.sq1_is_available testbench.processor_0.lsq1.inst2_op_type testbench.processor_0.lsq1.sq1_rob_idx testbench.processor_0.lsq1.lda1_valid testbench.processor_0.lsq1.n_sq_head1 testbench.processor_0.lsq1.n_sq_head2 testbench.processor_0.lsq1.inst2_type testbench.processor_0.lsq1.lq2_mem_data_in_valid testbench.processor_0.lsq1.lq2_clean testbench.processor_0.lsq1.cache_hit testbench.processor_0.lsq1.next_mem_inst testbench.processor_0.lsq1.lda1_result testbench.processor_0.lsq1.out2_is_sq1 testbench.processor_0.lsq1.inst1_opb_valid testbench.processor_0.lsq1.out2_is_sq2 testbench.processor_0.lsq1.thread2_mispredict testbench.processor_0.lsq1.sq1_dest_tag testbench.processor_0.lsq1.inst1_opb testbench.processor_0.lsq1.next_next_mem_valid testbench.processor_0.lsq1.lq1_is_available testbench.processor_0.lsq1.next_mem_valid testbench.processor_0.lsq1.lq1_rob_idx testbench.processor_0.lsq1.lsq_cdb1_valid testbench.processor_0.lsq1.lq2_is_available testbench.processor_0.lsq1.lq1_mem_in_temp2_2 }}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active _vcs_unit__497791245 sys_defs.vh
gui_src_value_annotate -id ${Source.1} -switch true
gui_set_env TOGGLE::VALUEANNOTATE 1
gui_view_scroll -id ${Source.1} -vertical -set 0
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 1500780 1501360
gui_list_add_group -id ${Wave.1} -after {New Group} {Group2}
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group Group2  -position in

gui_marker_move -id ${Wave.1} {C1} 1501070
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

