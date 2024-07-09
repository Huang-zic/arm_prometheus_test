import os
import pandas as pd

# 创建一个字典来统计每个 `a` 部分出现的次数
count={}
pn=['duration time','task clock','cpu-cycles','instructions','cache references','cache misses','branches','branch misses','L1 dcache loads',
    'L1 dcache load misses','LLC load misses','LLC load','IPC']
def process_txt_file(file_path,test_name):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        if len(lines) != 15:
            print(f"Warning: {file_path} does not contain exactly 14 lines.")
            return None
        if(count[test_name]>1):
            name=lines[0].strip()+lines[1].strip()
        else:
            name = lines[0].strip()
        data = []
        for i in range(2,len(lines)):
            # data[i-1][0]=name
            # data[i-1][1]=lines[i].strip()
            data.append([name,pn[i-2],lines[i].strip()])
        return data

def count_a_occurrences(directory):
    
    # 遍历目录中的所有文件
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.txt'):
                parts = file.split('-', 1)
                if len(parts) == 2:
                    test_name = parts[0]
                    if test_name in count:
                        count[test_name] += 1
                    else:
                        count[test_name] = 1
                    

def main(input_directory, output_file):
    count_a_occurrences(input_directory)
    all_data = []
    for file_name in os.listdir(input_directory):
        if file_name.endswith('.txt'):
            parts=file_name.split('-',1)
            file_path = os.path.join(input_directory, file_name)
            file_data = process_txt_file(file_path,parts[0])
            if file_data:
                for i in range(len(file_data)):
                    all_data.append(file_data[i])
    # Create a DataFrame
    columns = ['Test Name','Performance Name','Performance Value']
    df = pd.DataFrame(all_data, columns=columns)

    # Write DataFrame to an Excel file
    df.to_excel(output_file, index=False)
    print("save perf results success")
if __name__ == "__main__":
    input_directory = 'perf'  # Change to your directory
    output_file = 'perf_result.xlsx'
    main(input_directory, output_file)
