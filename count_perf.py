from msilib.schema import File
import os
import pandas as pd


pn=['duration time','task clock','cpu-cycles','instructions','cache references','cache misses','branches','branch misses','L1 dcache loads',
    'L1 dcache load misses','LLC load misses','LLC load','IPC']
def process_txt_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        if len(lines) != 14:
            print(f"Warning: {file_path} does not contain exactly 14 lines.")
            return None
        name = lines[0].strip()
        data = []
        for i in range(1,len(lines)):
            # data[i-1][0]=name
            # data[i-1][1]=lines[i].strip()
            data.append([name,pn[i-1],lines[i].strip()])
        return data

def main(input_directory, output_file):
    all_data = []

    for file_name in os.listdir(input_directory):
        if file_name.endswith('.txt'):
            file_path = os.path.join(input_directory, file_name)
            file_data = process_txt_file(file_path)
            if file_data:
                for i in range(len(file_data)):
                    all_data.append(file_data[i])
    print(len(all_data),len(all_data[0]))
    print(all_data[0])
    # Create a DataFrame
    columns = ['Test Name','Performance Name','Performance Value']
    df = pd.DataFrame(all_data, columns=columns)

    # Write DataFrame to an Excel file
    df.to_excel(output_file, index=False)

if __name__ == "__main__":
    input_directory = 'D:\MyProject\插值计算\插值计算\perf'  # Change to your directory
    output_file = 'perf_output.xlsx'
    main(input_directory, output_file)
