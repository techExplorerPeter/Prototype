#!/bin/bash -e

dat_dir=$1
out_dir=`pwd`/include/data_in
inc_dir=`pwd`/include
inc_head_file="$inc_dir/data_in_all.h"
echo "#ifndef _DATA_IN_ALL_H" > "$inc_head_file"
echo "#define __DATA_IN_ALL_H" >> "$inc_head_file" 
echo "" >> "$inc_head_file"
echo "#include <stdint.h>" >> "$inc_head_file"
echo "" >> "$inc_head_file"

cd $dat_dir
for dat_file in *.dat; do
    echo "$dat file"
    if [-f "$dat_file"]; then
        base_name=$(basename -- "$dat_file")
        file_name="${base_name%.*}"
        h_file="$out_dir/$file_name.h"
        include_file="$file_name.h"
        out_data0=`xxd -i-c 16 $dat_file`
        #out_datae='xxd -i-c 16 $dat_file sed 's/\([a-ZA-Z0-9_]*\)[\]/1]/
        #echo "Sout datae"

        #delete all strings before'{'
        #out_data1=$fout_data0##*{}
        #echo "Sout_data1"

        #delete all strings after '}
        #out_data2=out_data%\}*}
        #echo "Sout_data2"

        echo "#ifndef _${file_name}_H" > "$h_file"
        echo "#define _${file_name}_H" >> "$h_file"
        echo "" >> "$h_file"
        echo "#include <stdint.h>" >> "$h_file"
        echo "" >> "$h_file"
        # echo "extern const uint8_t $(file_name}[];">>"$h_file"
        # echo "extern const size_t $(file_name}_size;" > "$h_file"
        echo "" >> "$h_file"
        echo "$out_data0" >> $h_file
        echo "#endif // _${file_name}_H" >> "$h_file"
        echo "Generated $h_file"
        echo "#include \"./data_in/$include_file\"" >> "$inc_head_file"
    fi
done

echo "#define DSP_PARAMETERS_NAME (\"${dat_dir}\")" >> "$inc_head_file"
echo "" >> "$inc_head_file"
echo "" >> "$inc_head_file"
echo "" >> "$inc_head_file"
echo "#define GET_DATAIN_NAME(file_name)         (file_name##_dat)" >> "$inc_head_file"
echo "#define GET_DATAIN_SIZE(file_name)         (file_name##_dat_len)" >> "$inc_head_file"

echo "" >> "$inc_head_file"
echo "" >> "$inc_head_file"
echo "" >> "$inc_head_file"
echo "#endif // __DATA_IN_ALL_H" > "$inc_head_file"
echo "Generated $inc_head_file"
cd -

echo "trans done"
