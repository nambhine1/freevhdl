TestSuite TestHarness_frame 

SetLogSignals true



analyze TestCtrl_e.vhd
analyze TestHarness_frame_gen.vhd


#Testcases:

analyze Tb_send_data.vhd

simulate Tb_send_data