/data_center_01/home/mas/python3.6/bin/python3 check_result_structure.py -g /home/mas/metagenome_pipeline/html/main.cfg -c result_structure -o ../ -so out_config/result_structure.new # -eo out_config/result_structure.extra

# 复制文件
/data_center_01/home/mas/python3.6/bin/python3 cp_result_structure.py -c out_config/result_structure.new -so out_result/result -do out_result/data
