TestSuite TestHarness_axi_image_inv

SetLogSignals true



analyze TestCtrl_e.vhd
analyze TestHarness_image_inversion.vhd


#Testcases:

analyze Tb_send_data.vhd

simulate Tb_send_data