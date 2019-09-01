#!/home/test/.pyenv/shims/python3
#coding:utf8
#
import subprocess
import pathlib
import os
import sys
import time

os.system("ulimit -c 99999999999")
os.system("ulimit -n 999999")

def Input_1():  #当输入1或其他位置参数时，将修改各应用监听的端口
    port1 = "80{}1".format(input_1)
    port2 = "80{}2".format(input_1)

    find_comm =  'find . -name "ListenConfig.ini" -o -name "ConnSvr_Out.ini"'
    find_result = subprocess.check_output(find_comm,shell=True,stderr=subprocess.STDOUT,cwd="/home/test/pack")
    find_result = find_result.decode("utf-8")

    sed_falg = False
    for file in find_result.split("\n"):
        if len(file) > 0:
            port1_sed_command = "sed -i 's/80[0-9]1/{}/g' {}".format(port1,file)
            port2_sed_command = "sed -i 's/80[0-9]2/{}/g' {}".format(port2,file)
            subprocess.check_call(port1_sed_command,shell=True,cwd="/home/test/pack")
            subprocess.check_call(port2_sed_command,shell=True,cwd="/home/test/pack")
            sed_falg = True

    find_comm = 'find . -name "BootConfig.ini" -o -name "LanSvr.ini"'
    find_result = subprocess.check_output(find_comm,shell=True,stderr=subprocess.STDOUT,cwd="/home/test/pack")
    find_result = find_result.decode("utf-8")

    for file in find_result.split("\n"):
        if len(file) > 0 :
            for i in range(1,10):
                mod_port = "{}0{}1".format(i,input_1)
                sed_commmand = "sed -i 's/{}0[0-9]1/{}/g' {} ".format(i,mod_port,file)
                subprocess.check_call(sed_commmand,shell=True,cwd="/home/test/pack")

                sed_falg = True
    return sed_falg
def Input_2():  #当输入有第二个位置参数时
    if input_2 != None:
        sed_commmand = "sed -i 's/nPlayerNum = [0-9]/nPlayerNum = {}/g'".format(input_2)
        subprocess.check_call(sed_commmand,shell=True)

def find_svr(): #找出/home/test/pack目录下包括svr的子目录，以及正在运行中的各svr进程号及目录
    svr_name_list = []
    svr_run_path_list = []
    pack_directory = pathlib.Path("/home/test/pack")
    for directory in pack_directory.glob("*"):  # 找出所有的svr目录名称及svr_run.**执行脚本名称
        if directory.is_dir():
            tmp_directory = directory.parts
            if "svr" in tmp_directory[-1]:
                if "chess_svr" in tmp_directory[-1]:
                    find_svr_run = "chess_svr" + "." + "run*"
                else:
                    find_svr_run = tmp_directory[-1] + "." + "run*"
                find_commmand = 'find ./{} -name "{}"'.format(tmp_directory[-1], find_svr_run)
                find_result = subprocess.check_output(find_commmand, shell=True, cwd="/home/test/pack",
                                                      stderr=subprocess.STDOUT)
                find_result = find_result.decode("utf-8")
                find_result = find_result.split("\n")
                svr_name_list.append(tmp_directory[-1])
                svr_run_path_list.append(find_result[0])

    return [svr_name_list,svr_run_path_list]

def kill(): #kill掉所有svr进程
    svr_name_list,_ = find_svr()
    for svr in svr_name_list: #删除进程
        ps_command = "ps xf | grep %s.*.run.* |  grep -v grep | awk '{ print $1,$5}'" % svr

        ps_command_result = subprocess.check_output(ps_command, shell=True, stderr=subprocess.STDOUT)
        ps_command_result = ps_command_result.decode("utf-8")
        if len(ps_command_result) == 0:
            continue
        ps_command_result = ps_command_result.split("\n")
        ps_command_result = ps_command_result[0].split(" ")

        process = ps_command_result[0]
        process_dir = ps_command_result[1]

        find_process_command = "ls -l /proc/%s/cwd |awk '{print $11}'|grep '/home/test/pack/'" % process
        find_process_command_result = subprocess.check_output(find_process_command, shell=True, stderr=subprocess.STDOUT)
        find_process_command_result = find_process_command_result.decode("utf-8")
        find_process_command_result = find_process_command_result.split("\n")

        if len(find_process_command_result[0]) > 0:
            print("正在停止 {} 进程,进程号{}".format(process_dir, process))
            kill_command = "kill -9 {}".format(process)
            subprocess.check_output(kill_command, shell=True)
            time.sleep(1)

def default():  #启动svr进程。当chess_svr有多个时，只启动数值最大的两个chess_svr
    svr_name_list,svr_run_path_list = find_svr()
    tmp_chess = []
    if len(svr_run_path_list) > 6:
        for i in svr_run_path_list:
            _i = i.split("/")
            if "chess_svr" == _i[1]:
                svr_run_path_list.remove(i)
            elif "chess_svr" in _i[1]:
                _tmp = (_i[1].split("chess_svr"))[1]
                tmp_chess.append(int(_tmp)) if _tmp.isdigit() else print("{}命名不符合规则")

        if len(tmp_chess) > 2:
            first_chess_svr, second_chess_svr = sorted(tmp_chess)[-1], sorted(tmp_chess)[-2]
            tmp_chess.remove(first_chess_svr)
            tmp_chess.remove(second_chess_svr)
            tmp_list = []

            for i in svr_run_path_list:
                _i = i.split("/")
                if "chess_svr" in _i[1]:
                    _tmp = (_i[1].split("chess_svr"))[1]
                    tmp_list.append(i) if int(_tmp) not in tmp_chess else None
                else:
                    tmp_list.append(i)

            for i in tmp_list:
                print("正在启动 {} 进程".format(i))
                subprocess.check_call(i, shell=True, cwd="/home/test/pack")
        else:
            for i in svr_run_path_list:
                print("正在启动 {} 进程".format(i))
                subprocess.check_call(i, shell=True, cwd="/home/test/pack")
    else:
        for i in svr_run_path_list:
            print("正在启动 {} 进程".format(i))
            subprocess.check_call(i, shell=True, cwd="/home/test/pack")


if __name__ =="__main__":
    try:
        input_1 = sys.argv[1]
    except IndexError:
        input_1 = None

    try:
        input_2 = sys.argv[2]
    except IndexError:
        input_2 = None

    if input_1 == "stop":
        kill()
    elif input_1 != None and input_1.isdigit():
        run_stat = Input_1()
        if run_stat:
            kill()
            default()
        else:
            print("文件修改错误")
        if input_2 != None:
            Input_2()

    elif input_1 == None:
        kill()
        default()









