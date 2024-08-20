import os
import pandas as pd

print("start processing test results")
# 创建一个字典来统计每个 `a` 部分出现的次数
count={}
def process_txt_file(file_path,test_name):
    data = []
    with open(file_path, 'r',errors='ignore') as file:
        lines=file.readlines()
        flag=' '
        status='Y'
        test_position=0
        test_start=lines[0].strip()
        for i in range(len(lines)):
            if lines[i].startswith("=== RUN")  :
                test_start=lines[i].strip()
                test_position=1
                break
            if lines[i].startswith("testing: warning: no tests to run"):
                test_start=lines[i].strip()
                break
        if test_position==1 :
            for i in range(len(lines)):
                if lines[i].startswith("--- PASS"):
                    flag=lines[i].strip()
                    break
                elif lines[i].startswith("--- SKIP"):
                    flag=lines[i].strip()
                    break
                elif lines[i].startswith("--- FAIL"):
                    flag=lines[i].strip()
                    break
        if(len(lines)<5 or lines[-4].strip()!='PASS'):
            print("go test error \n","file_path:",lines[-1],"\ntest_name:",test_name)
            status='N'
            name=lines[-2].strip()+lines[-1].strip()
            detail="'"
            for i in range(len(lines)-2):
                detail=detail+lines[i].strip()+"\n"
            data.append([name,status,"'"+test_start+"\n"+lines[-3].strip()+"\n"+flag])
            return data
        if(count[test_name]>1):
            name=lines[-2].strip()+lines[-1].strip()
        else:
            name = lines[-2].strip()
        detail="'"+ test_start+"\n"+flag+"\n"+lines[-4].strip()
        data.append([name,status,detail])
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
    columns = ['Test Name','Status','Run Details']
    df = pd.DataFrame(all_data, columns=columns)

    # Write DataFrame to an Excel file
    df.to_excel(output_file, index=False)
    print("success save test results to test_result.xlsx")
if __name__ == "__main__":
    input_directory = 'test'  # Change to your directory
    output_file = 'test_result.xlsx'
    main(input_directory, output_file)




