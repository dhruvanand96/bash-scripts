#!/bin/bash
input="./students.records"

array=( "$@" )
arraylength=${#array[@]}
for (( i=0; i<${arraylength}; i++ ));
do
  echo "${array[$i]}"
done

if  [ $arraylength -gt 2 ]
then
  echo "only 2 arguments allowed"
  exit 0
fi

if [ -f "${array[0]}" ] && [ -f "${array[1]}" ]; then
  echo "files exists."
else
  echo "files does not exist."
  exit 0
fi

declare -a students_rec
declare -A students_dic
student_keys=("First name" "Last name" "Student Number" "username")
n=1
index=0
while IFS= read -r line
do
  if [ $n -eq 1 ];then
    IFS=","
    read -ra ADDR <<<"$line"
    for i in "${ADDR[@]}";do
      for x in "${student_keys[@]}";do
        if [ "$x" = "$i | xargs" ] ; then
          echo "$i Key not Found"
        fi
      done
    done
  else
    count=0
    read -ra ADDR <<<"$line"
    for i in "${ADDR[@]}";do
      i="${i#"${i%%[![:space:]]*}"}"
      i="${i%"${i##*[![:space:]]}"}"
      students_dic[${student_keys[$count]}]=$i
      count=$((count+1))
    done

    string=$(declare -p students_dic)

    students_rec[$index]=${string}
    index=$((index+1))

  fi
  n=$((n+1))
done < ${array[0]}

for KEY in "${!students_rec[@]}"; do
  TMP="${students_rec["$KEY"]}"
  echo "$KEY - $TMP"
done

declare -A wieghts_rec
declare -A wieghts_dic
wieghts_keys=("Course Work" "Maximum Possible Mark" "Weight")
n=1
index=0
while IFS= read -r line; do
  if [ $n -eq 1 ];then
    IFS=','
    read -ra ADDR <<<"$line"
    for i in "${ADDR[@]}";do
      for x in "${wieghts_keys[@]}";do
        if [ "$x" = "$i | xargs" ] ; then
          echo " $i Key not Found"
        fi
      done
    done
  else
    count=0
    IFS=','
    read -ra ADDR <<<"$line"
    for i in "${ADDR[@]}";do
      i="${i#"${i%%[![:space:]]*}"}"                                            
      i="${i%"${i##*[![:space:]]}"}" 
      wieghts_dic[${wieghts_keys[$count]}]=$i
      count=$((count+1))
    done

    string=$(declare -p wieghts_dic)

    wieghts_rec[$index]=${string}
    index=$((index+1))
    fi
    n=$((n+1))
done < ${array[1]}

for KEY in "${!wieghts_rec[@]}"; do
    TMP="${wieghts_rec["$KEY"]}"
    echo "$KEY - $TMP"
done


EXT=marks
declare -A Marks
mark_keys=("username" "marks" "filename")
index=0
for i in *; do
  declare -A mark_dic
  if [ "${i}" != "${i%.${EXT}}" ];then
    echo "I do something with the file $i"
    echo "${i%%.*}"
    while IFS= read -r line; do
        count=0
        IFS=','
        read -ra ADDR <<<"$line"
        for z in "${ADDR[@]}";do
          z="${z#"${z%%[![:space:]]*}"}"
          z="${z%"${z##*[![:space:]]}"}"
          mark_dic[${mark_keys[$count]}]=$z
          count=$((count+1))
        done

        mark_dic[${mark_keys[$count]}]=${i%%.*}

        string=$(declare -p mark_dic)
        Marks[$index]=${string}
        index=$((index+1))
    done < ${i}
  fi
done

for KEY in "${!Marks[@]}"; do
  TMP="${Marks["$KEY"]}"
  echo "$KEY - $TMP"
done

#output preparation
output_keys=("First name" "Last name" "Student Number" "username" "A1" "A2" "Total" "Grade")


for KEY in "${!students_rec[@]}"; do
  #printf "$KEY - ${students_rec["$KEY"]}\n"
  eval "${students_rec["$KEY"]}"
  #printf "${students_rec["$KEY"]}\n"
  echo "${students_dic["$KEY"]}"
  A1=0.0
  A2=0.0
  total=0

  for mark in "${!Marks[@]}"; do
    eval "${Marks["$mark"]}"
    if [ "${mark_dic["filename"]}" == "A1" ] && [ "${mark_dic['username']}" == "${students_dic['username']}" ]; then
      A1=${mark_dic["marks"]}
    fi

    if [ "${mark_dic["filename"]}" == "A2" ] && [ "${mark_dic['username']}" == "${students_dic['username']}" ]; then
      A2=${mark_dic["marks"]}
    fi

  done

  total=$(echo "$A1 + $A2" | bc)

  echo "${students_dic["First name"]} ${students_dic["Last name"]} ${students_dic["Student Number"]} ${students_dic["username"]} $A1 $A2 $total "

 # for KEY in "${!students_dic[@]}"; do
 #   printf "*$KEY* - ${students_dic["$KEY"]}\n"
 # done
done
