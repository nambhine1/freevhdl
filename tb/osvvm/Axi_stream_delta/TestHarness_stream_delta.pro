TestSuite TestHarness_axi_stream_delta 

SetLogSignals true



analyze TestCtrl_e.vhd
analyze TestHarness_stream_delta.vhd


#Testcases:

analyze Tb_send_data.vhd

simulate Tb_send_data