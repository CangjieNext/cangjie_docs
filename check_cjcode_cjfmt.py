import os
import re
from datetime import datetime
import argparse
import subprocess
import platform
import shutil

def remove_trailing_empty_lines(lines):
    """删除末尾的空行或只包含空格的行"""
    while lines and (not lines[-1].strip() or lines[-1].strip() == ''):
        lines.pop()
    return lines

def remove_whitespace_lines(lines):
    """
    处理代码行，将只包含空格的行替换为空行
    """
    processed_lines = []
    for line in lines:
        if line and not line.strip():  # 只包含空格的行
            processed_lines.append("")  # 替换为空行
        else:
            processed_lines.append(line)
    return processed_lines

def extract_and_normalize_code_blocks(markdown_text):
    """
    提取Markdown中的Cangjie代码块，忽略引用块中的代码块
    并去除代码内容的公共缩进，记录缩进信息
    """
    lines = markdown_text.split('\n')
    i = 0
    code_blocks = []  # 存储 (去除了公共缩进的代码, 原始缩进, 代码块序号)
    in_code_block = False
    in_quote_block = False
    current_block = []
    block_start_indent = ""
    block_start_line = 0
    
    while i < len(lines):
        line = lines[i]
        
        # 检查是否在引用块中
        stripped_line = line.lstrip()
        if stripped_line.startswith('>'):
            in_quote_block = True
        elif line.strip() == '':
            pass
        else:
            in_quote_block = False
        
        # 检查是否是代码块开始标记
        code_start_match = re.match(r'^([ \t]*)```cangjie', line)
        if code_start_match and not in_quote_block:
            in_code_block = True
            block_start_indent = code_start_match.group(1)  # 记录代码块的原始缩进
            block_start_line = i
            current_block = []
            i += 1
            continue
        
        if in_code_block:
            if re.match(r'^[ \t]*```', line):
                # 结束代码块，处理当前块
                if current_block:
                    # 1. 首先处理只包含空格的行
                    cleaned_block = remove_whitespace_lines(current_block)
                    
                    # 2. 计算代码内容的公共缩进
                    min_indent = float('inf')
                    non_empty_lines = []
                    for code_line in cleaned_block:
                        if code_line.strip():  # 非空行
                            leading_spaces = len(code_line) - len(code_line.lstrip(' '))
                            min_indent = min(min_indent, leading_spaces)
                            non_empty_lines.append(code_line)
                    
                    # 3. 如果没有非空行，min_indent保持inf
                    if min_indent == float('inf'):
                        min_indent = 0
                    
                    # 4. 去除公共缩进
                    normalized_lines = []
                    for code_line in cleaned_block:
                        if code_line.strip():
                            # 去掉公共缩进
                            if len(code_line) > min_indent:
                                normalized_line = code_line[min_indent:]
                            else:
                                normalized_line = code_line.lstrip()
                            normalized_lines.append(normalized_line)
                        else:
                            normalized_lines.append("")  # 保留空行
                    
                    normalized_code = '\n'.join(normalized_lines)
                    
                    # 5. 存储代码块信息
                    code_blocks.append({
                        'code': normalized_code,
                        'original_indent': block_start_indent,
                        'block_start_line': block_start_line,
                        'content_indent': min_indent  # 记录内容缩进
                    })
                
                in_code_block = False
            else:
                current_block.append(line)
        
        i += 1
    
    return code_blocks

def save_normalized_code_blocks(code_blocks_info, folder_name):
    """保存去除了公共缩进的代码块和元数据"""
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
    
    for i, block_info in enumerate(code_blocks_info, start=1):
        # 保存代码文件
        file_name = os.path.join(folder_name, f"{i}.cj")
        with open(file_name, 'w', encoding='utf-8') as file:
            file.write(block_info['code'])
        
        # 保存元数据
        meta_file = os.path.join(folder_name, f"{i}.meta")
        with open(meta_file, 'w', encoding='utf-8') as f:
            f.write(f"original_indent: {repr(block_info['original_indent'])}\n")
            f.write(f"content_indent: {block_info['content_indent']}\n")

def create_folder_with_current_time(base_directory):
    """创建以当前时间命名的文件夹"""
    current_time = datetime.now().strftime("%Y%m%d%H%M%S")
    new_folder_name = f"CJFormat_{current_time}"
    new_folder_path = os.path.join(base_directory, new_folder_name)
    
    os.makedirs(new_folder_path, exist_ok=True)
    return new_folder_path

def replicate_directory_structure(source_directory, target_directory, new_folder_name):
    """
    遍历原文件夹的层级结构，提取并归一化代码块
    """
    new_folder_path = os.path.join(target_directory, new_folder_name)
    if not os.path.exists(new_folder_path):
        os.makedirs(new_folder_path, exist_ok=True)
    
    # 遍历原文件夹的层级结构
    for root, dirs, files in os.walk(source_directory):
        # 构建新的子文件夹路径，包括原始文件夹的名称
        relative_path = os.path.relpath(root, source_directory)
        new_subdir = os.path.join(new_folder_path, relative_path)
        
        # 创建空子文件夹
        if not os.path.exists(new_subdir):
            os.makedirs(new_subdir, exist_ok=True)
        
        # 遍历当前目录下的所有文件
        for file in files:
            if file.endswith('.md'):
                # 构建完整的文件路径
                file_path = os.path.join(root, file)
                # 读取 Markdown 文件内容
                try:
                    with open(file_path, 'r', encoding='utf-8') as markdown_file:
                        markdown_text = markdown_file.read()
                    
                    # 提取并归一化 Cangjie 代码块
                    cangjie_code_blocks_info = extract_and_normalize_code_blocks(markdown_text)
                    
                    # 创建以 Markdown 文件名命名的子文件夹
                    markdown_folder_name = os.path.splitext(file)[0]
                    markdown_folder_path = os.path.join(new_subdir, markdown_folder_name)
                    os.makedirs(markdown_folder_path, exist_ok=True)
                    
                    # 保存归一化的代码块和元数据
                    save_normalized_code_blocks(cangjie_code_blocks_info, markdown_folder_path)
                    
                    print(f"处理文件: {file_path}, 提取到 {len(cangjie_code_blocks_info)} 个代码块")
                except Exception as e:
                    print(f"处理文件 {file_path} 时出错: {e}")

def execute_sys_command(command):
    """执行系统命令"""
    try:
        # 根据操作系统决定shell参数和命令格式
        is_windows = platform.system() == "Windows"
        
        # 在Windows下，显式指定UTF-8编码
        env = os.environ.copy()
        if is_windows:
            env['PYTHONIOENCODING'] = 'utf-8'
        
        result = subprocess.run(
            command, 
            stderr=subprocess.PIPE, 
            stdout=subprocess.PIPE,
            text=True, 
            check=True, 
            shell=True,
            encoding='utf-8',
            errors='ignore',
            env=env
        )
        return True
    except subprocess.CalledProcessError as e:
        try:
            error_msg = e.stderr.decode('utf-8')
        except:
            try:
                error_msg = e.stderr.decode('gbk', errors='ignore')
            except:
                error_msg = str(e.stderr)
        print(f"命令执行失败: {error_msg}")
        return False
    except FileNotFoundError as e:
        print(f"命令未找到: {command}")
        return False
    except Exception as e:
        print(f"执行命令时发生未知错误: {e}")
        return False

def compare_files(file1, file2):
    """比较两个文件内容是否相同（忽略行首空白）"""
    try:
        with open(file1, 'r', encoding='utf-8') as f1, open(file2, 'r', encoding='utf-8') as f2:
            content1 = f1.read()
            content2 = f2.read()
            
            if content1 == content2:
                return True
            
            lines1 = content1.splitlines()
            lines2 = content2.splitlines()
            
            min_len = min(len(lines1), len(lines2))
            
            for i in range(min_len):
                if lines1[i].lstrip() != lines2[i].lstrip():
                    return False
            
            return True
    except Exception as e:
        print(f"比较文件时出错 {file1} vs {file2}: {e}")
        return False

def compare_directories(dir1, dir2, diff_file, same_file):
    """比较两个目录中的.cj文件"""
    diff_files = []
    same_files = []
    isSame_flag = True

    for root, _, files in os.walk(dir1):
        relative_path = os.path.relpath(root, dir1)
        dir2_path = os.path.join(dir2, relative_path)

        for file in files:
            if file.endswith('.cj'):
                file1_path = os.path.join(root, file)
                file2_path = os.path.join(dir2_path, file)

                if os.path.exists(file2_path):
                    if compare_files(file1_path, file2_path):
                        same_files.append(f"{file1_path}")
                    else:
                        diff_files.append(f"{file2_path}")
                else:
                    diff_file.write(f"只存在于 {dir1}: {file1_path}\n\n")
        
        # 检查dir2中是否有dir1不存在的文件
        if os.path.exists(dir2_path):
            for file in os.listdir(dir2_path):
                file2_full_path = os.path.join(dir2_path, file)
                if file.endswith('.cj') and not os.path.exists(os.path.join(root, file)):
                    diff_file.write(f"只存在于 {dir2}: {file2_full_path}\n\n")

    if diff_files:
        isSame_flag = False
        diff_file.write("有差异的文件列表：\n")
        for diff_f in diff_files:
            diff_file.write(f"{diff_f}\n")
    else:
        diff_file.write("没有发现有差异的文件。\n")
    
    if same_files:
        same_file.write("无差异的文件列表：\n")
        for same_f in same_files:
            same_file.write(f"{same_f}\n")
    else:
        same_file.write("没有发现无差异的文件。\n")
    
    return isSame_flag

def fix_code_block_markers(markdown_content):
    """修复代码块标记问题，特别是结尾 ``` 的缩进问题"""
    pattern = re.compile(r'^([ \t]*)```cangjie\s*\n(.*?)\n([ \t]*)```', re.DOTALL | re.MULTILINE)
    
    last_end = 0
    fixed_parts = []
    
    for match in pattern.finditer(markdown_content):
        fixed_parts.append(markdown_content[last_end:match.start()])
        
        start_indent = match.group(1)
        content = match.group(2)
        end_indent = match.group(3)
        
        if end_indent != start_indent:
            print(f"修复代码块标记：开头缩进 {len(start_indent)} 个空格，结尾缩进 {len(end_indent)} 个空格，已调整为一致")
            fixed_block = f"{start_indent}```cangjie\n{content}\n{start_indent}```"
            fixed_parts.append(fixed_block)
        else:
            fixed_parts.append(match.group(0))
        
        last_end = match.end()
    
    fixed_parts.append(markdown_content[last_end:])
    return ''.join(fixed_parts)

def code_replace(replaced_docs_dir, gold_cj_dir, extract_cj_dir):
    """
    用格式化后的代码替换Markdown中的代码块
    
    replaced_docs_dir: 要替换的文档目录
    gold_cj_dir: 格式化后的代码目录（已去除公共缩进）
    extract_cj_dir: 原始提取的代码目录（包含元数据）
    """
    # 遍历replaced_docs_dir目录
    for root, dirs, files in os.walk(replaced_docs_dir):
        for file in files:
            if file.endswith(".md"):
                # 获取当前 markdown 文件路径
                markdown_file_path = os.path.join(root, file)

                # 计算对应的文件夹路径
                relative_path = os.path.relpath(root, replaced_docs_dir)
                gold_folder = os.path.join(gold_cj_dir, relative_path, file[:-3])  # 去掉 .md 扩展名
                extract_folder = os.path.join(extract_cj_dir, relative_path, file[:-3])

                if not os.path.exists(gold_folder) or not os.path.exists(extract_folder):
                    print(f"找不到对应的文件夹: {gold_folder} 或 {extract_folder}")
                    continue
                
                # 读取 markdown 文件内容
                try:
                    with open(markdown_file_path, "r", encoding="utf-8") as md_file:
                        markdown_content = md_file.read()
                    
                    # 首先修复代码块标记问题
                    markdown_content = fix_code_block_markers(markdown_content)
                    
                    # 使用正则表达式查找所有代码块
                    pattern = re.compile(r'^([ \t]*)```cangjie\s*\n(.*?)\n[ \t]*```', re.DOTALL | re.MULTILINE)
                    
                    # 存储替换结果
                    last_end = 0
                    result_parts = []
                    code_block_idx = 0
                    
                    for match in pattern.finditer(markdown_content):
                        # 添加匹配前的文本
                        result_parts.append(markdown_content[last_end:match.start()])
                        
                        indent = match.group(1)  # 代码块的缩进
                        
                        code_block_idx += 1
                        gold_file = os.path.join(gold_folder, f"{code_block_idx}.cj")
                        
                        if not os.path.exists(gold_file):
                            print(f"缺少格式化后的.cj文件: {gold_file}")
                            # 保留原始代码块
                            result_parts.append(match.group(0))
                        else:
                            # 读取格式化后的代码（已去除公共缩进）
                            with open(gold_file, "r", encoding="utf-8") as cj_file:
                                formatted_code = cj_file.read().rstrip('\n')
                            
                            # 构建新的代码块
                            new_block = f"{indent}```cangjie\n"
                            
                            # 添加代码内容，直接使用格式化后的代码，只添加外层缩进
                            if formatted_code:
                                lines = formatted_code.split('\n')
                                
                                # 处理只包含空格的行
                                lines = remove_whitespace_lines(lines)
                                
                                # 删除末尾的空行
                                lines = remove_trailing_empty_lines(lines)
                                
                                # 对于每一行，直接添加代码块的缩进
                                for line in lines:
                                    if line == "":
                                        new_block += "\n"
                                    else:
                                        new_block += f"{indent}{line}\n"
                            
                            # 添加结束标记，使用原始缩进
                            new_block = new_block.rstrip('\n') + f"\n{indent}```"
                            
                            result_parts.append(new_block)
                        
                        last_end = match.end()
                    
                    # 添加最后一部分文本
                    result_parts.append(markdown_content[last_end:])
                    
                    # 组合结果
                    new_markdown_content = ''.join(result_parts)
                    
                    # 写回到 markdown 文件
                    with open(markdown_file_path, "w", encoding="utf-8") as md_file:
                        md_file.write(new_markdown_content)
                        
                    print(f"已处理文件: {markdown_file_path}")
                        
                except Exception as e:
                    print(f"处理文件 {markdown_file_path} 时出错: {e}")

def main():
    # 检测操作系统
    is_windows = platform.system() == "Windows"
    print(f"当前操作系统: {'Windows' if is_windows else 'Linux/Mac'}")

    # 检查仓颉工具链是否安装
    check_command = "cjc -v" if not is_windows else "cjc.exe -v"
    print(f"检查命令: {check_command}")
    check_cjc_result = execute_sys_command(check_command)

    if check_cjc_result:
        # 提取仓颉源码，默认路径docs/
        parser = argparse.ArgumentParser(description="提取仓颉文档源代码")
        parser.add_argument('--folderName', type=str, help='文档包路径', default='docs')
        parser.add_argument('--replace', nargs='?', type=int, choices=[0, 1], const=True, default=None, help='替换需要优化的代码。0表示在原位置替换，1表示在文件夹dir内输出替换。')
        args = parser.parse_args()

        source_directory = args.folderName
        base_directory = ''

        # 创建以当前时间命名的文件夹
        time_named_folder = create_folder_with_current_time(base_directory)
        print("仓颉源码存储路径：" + time_named_folder)

        # 在新文件夹下构建原始文件夹的目录层级并查找Markdown文件
        replicate_directory_structure(source_directory, time_named_folder, 'extract_cj')
        print("仓颉源码提取成功（已去除公共缩进）。")

        # 格式化代码
        source_extract_dir = os.path.join(time_named_folder, 'extract_cj')
        target_gold_dir = os.path.join(time_named_folder, 'gold_cj')

        try:
            # 使用shutil进行跨平台文件复制
            if os.path.exists(target_gold_dir):
                shutil.rmtree(target_gold_dir)
            shutil.copytree(source_extract_dir, target_gold_dir)
            print("文档拷贝成功。")

            # 格式化命令
            cjfmt_command = f'cjfmt -d "{target_gold_dir}"'
            if is_windows:
                cjfmt_command = f'cjfmt -d "{target_gold_dir}"'
            else:
                cjfmt_command = f'cjfmt -d "{target_gold_dir}" > /dev/null 2>&1'
            
            print(f"执行格式化命令: {cjfmt_command}")
            
            # 运行两次cjfmt以确保完全格式化
            execute_sys_command(cjfmt_command)
            check_cjfmt_result = execute_sys_command(cjfmt_command)
            
            if check_cjfmt_result:
                print("代码格式化成功。")
            else:
                print("仓颉源码格式化失败，请检查仓颉工具链。")
            
        except Exception as e:
            print(f"文档拷贝失败: {e}")

        # 输出对比结果
        diff_file_path = os.path.join(time_named_folder, 'diff.txt')
        same_file_path = os.path.join(time_named_folder, 'same.txt')
        source_dir = os.path.join(time_named_folder, 'extract_cj')
        gold_dir = os.path.join(time_named_folder, 'gold_cj')

        with open(diff_file_path, 'w', encoding='utf-8') as diff_file, open(same_file_path, 'w', encoding='utf-8') as same_file:
            answer_flag = compare_directories(source_dir, gold_dir, diff_file, same_file)
            print("检测结果: " + str(answer_flag))
            if not answer_flag:
                print("需要优化的代码详情请查看:" + os.path.abspath(diff_file_path))
            else:
                print("没有需要优化的代码。")
        
        # 输出替换文档
        if args.replace is True:
            parser.error("必须指定替换位置！使用0表示在原位置替换，1表示输出一个新文件夹。")
        elif args.replace == 0:
            replaced_dir = source_directory
            code_replace(replaced_dir, gold_dir, source_extract_dir)
            print("代码已在原位置替换完成。")
        elif args.replace == 1:
            replaced_dir = os.path.join(time_named_folder, 'replaced_docs')
            try:
                if os.path.exists(replaced_dir):
                    shutil.rmtree(replaced_dir)
                shutil.copytree(source_directory, replaced_dir)
                code_replace(replaced_dir, gold_dir, source_extract_dir)
                print(f"代码已在新位置替换完成: {replaced_dir}")
            except Exception as e:
                print(f"文档拷贝错误: {e}")

    else:
        print("错误！请安装仓颉工具链。")

if __name__ == "__main__":
    main()