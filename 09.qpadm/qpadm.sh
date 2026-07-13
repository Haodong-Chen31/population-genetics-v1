#!/bin/bash

# 用法: sh qpAdm_power_iterator.sh [merged_path] [target_file] [source_file] [right_file] [strategy: rotating/non-rotating]

fn=$1
target_file=$2
source_file=$3
right_file=$4
STRATEGY=$5 # non-rotating or rotating strategy
parallel_threads=$6

# 检查参数
if [ $# -lt 5 ]; then
    echo "Usage: sh $0 [merged_path] [target_file] [source_file] [right_file] [rotating/non-rotating]"
    exit 1
fi

echo "Starting pre-run validation..."

# 1. 提取所有输入文件中的人群名单
all_targets=$(grep -v "^$" "$target_file")
all_sources=$(grep -v "====" "$source_file" | grep -v "^$")
all_rights=$(grep -v "^$" "$right_file")

# 2. 检查所有人群是否都在 .ind 文件的第三列中存在
if [ ! -f "${fn}.ind" ]; then
    echo "Error: Genotype index file ${fn}.ind not found."
    exit 1
fi

# 提前提取 .ind 的第三列到内存，极大提高校验速度
mapfile -t ind_pops < <(awk '{print $3}' "${fn}.ind" | sort -u)

missing_pops=""
for p in $all_targets $all_sources $all_rights; do
    found=0
    for exist_p in "${ind_pops[@]}"; do
        if [ "$p" == "$exist_p" ]; then
            found=1
            break
        fi
    done
    if [ $found -eq 0 ]; then
        missing_pops+="$p "
    fi
done

if [ -n "$missing_pops" ]; then
    echo "Error: The following populations are missing from ${fn}.ind:"
    echo ">> $missing_pops"
    exit 1
fi

# 3. 检查文件之间是否有重复元素
check_overlap() {
    local file1_name=$1
    local file2_name=$2
    local list1=$3
    local list2=$4
    
    # 使用 grep -Fxf 比 comm 更简单地获取交集
    overlap=$(grep -Fxf <(echo "$list1" | sort -u) <(echo "$list2" | sort -u))
    
    if [ -n "$overlap" ]; then
        echo "Error: Overlapping populations found between $file1_name and $file2_name:"
        echo "$overlap" | sed 's/^/  - /'
        return 1
    fi
}

# 执行重复项检查
err=0
check_overlap "target_file" "source_file" "$all_targets" "$all_sources" || err=1
check_overlap "target_file" "right_file"  "$all_targets" "$all_rights"  || err=1
check_overlap "source_file" "right_file"  "$all_sources" "$all_rights"  || err=1

if [ $err -ne 0 ]; then
    echo "Validation failed. Please resolve population overlaps and try again."
    exit 1
fi

echo "Validation passed. Proceeding to task generation..."

DIR=$(pwd)
RUN_DIR="${DIR}/output"
rm -rf ${RUN_DIR} ; mkdir -p ${RUN_DIR}

# 1. 预处理 source.txt：将人群按标签存入临时文件，方便 Python 读取
# 这样可以避免 Bash 数组传参给 Python 时出现的引号和换行符问题
TEMP_SOURCE_JSON="${DIR}/.source_data.txt"
> "$TEMP_SOURCE_JSON"

sources=($(grep "====" "$source_file" | sed 's/====//g'))
for s in "${sources[@]}"; do
    pops=$(sed -n "/====${s}====/,/====/p" "$source_file" | grep -v "====" | grep -v "^$" | tr '\n' ',')
    echo "${s}:${pops%,}" >> "$TEMP_SOURCE_JSON"
done

# 获取所有人群列表
all_source_pops=$(grep -v "====" "$source_file" | grep -v "^$" | sort -u)

# 2. 修改后的 Python 逻辑
# 从临时文件读取数据，确保 100% 准确性
generate_pop_combos() {
    python3 - <<EOF
import itertools

# 读取预处理的数据
tag_map = {}
with open("$TEMP_SOURCE_JSON", "r") as f:
    for line in f:
        if ":" in line:
            tag, pops = line.strip().split(":")
            tag_map[tag] = pops.split(",")

tags = list(tag_map.keys())

# 遍历 1-way 到 n-way
for r in range(1, len(tags) + 1):
    # 选出标签组合
    for tag_combo in itertools.combinations(tags, r):
        # 对选出标签下的人群做笛卡尔积
        tag_pops = [tag_map[t] for t in tag_combo]
        for pop_combo in itertools.product(*tag_pops):
            print(f"{r} {' '.join(pop_combo)}")
EOF
}

# 3. 生成任务
> qpAdm.parl
mapfile -t targets < "$target_file"

for elem in "${targets[@]}"; do
    # 移除可能存在的换行符
    elem=$(echo "$elem" | tr -d '\r\n')
    echo "Generating tasks for target: $elem ..."
    
    # 捕获 Python 输出并循环
    while read -r line; do
        [ -z "$line" ] && continue
        parts=($line)
        way=${parts[0]}
        current_pops=("${parts[@]:1}")
        
        # 文件夹命名
        combo_name=$(IFS=-; echo "${current_pops[*]}")
        OUTDIR="${RUN_DIR}/${elem}/${way}-way/${combo_name}"
        mkdir -p "${OUTDIR}"

        # --- 构造 Left ---
        echo "$elem" > "${OUTDIR}/left.pops"
        for p in "${current_pops[@]}"; do
            echo "$p" >> "${OUTDIR}/left.pops"
        done

        # --- 构造 Right ---
        cp "$right_file" "${OUTDIR}/right.pops"
        
        if [ "$STRATEGY" == "rotating" ]; then
            for p in $all_source_pops; do
                is_selected=false
                for sel in "${current_pops[@]}"; do
                    if [ "$p" == "$sel" ]; then is_selected=true; break; fi
                done
                if [ "$is_selected" = false ]; then
                    echo "$p" >> "${OUTDIR}/right.pops"
                fi
            done
            sort -u "${OUTDIR}/right.pops" -o "${OUTDIR}/right.pops"
        fi

        # --- 构造参数文件 ---
        PAR_FILE="${OUTDIR}/run.par"
        {
            echo "genotypename: ${fn}.geno"
            echo "snpname: ${fn}.snp"
            echo "indivname: ${fn}.ind"
            echo "popleft: ${OUTDIR}/left.pops"
            echo "popright: ${OUTDIR}/right.pops"
            echo "details: YES"
            echo "llsnps: YES"
            echo "inbreed: YES"
        } > "${PAR_FILE}"

        echo "qpAdm -p ${PAR_FILE} > ${OUTDIR}/result.txt" >> qpAdm.parl
    done < <(generate_pop_combos)
done

# 清理临时文件
rm "$TEMP_SOURCE_JSON"

echo "Created $(wc -l < qpAdm.parl) tasks in qpAdm.parl"

# 并行运行qpAdm.parl
cat qpAdm.parl | parallel -j ${parallel_threads} --joblog qpAdm.log
