output_filename="/tmp/bj-weather"

wget -O $output_filename http://bj.weather.com.cn/

temp=`cat $output_filename | grep "气&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;温" | awk -F "：" '{print $2}' | awk -F "<" '{print $1}'`
humidity=`cat $output_filename | grep "<span>相对湿度" | awk -F "：" '{print $2}' | awk -F "<" '{print $1}'`

echo "气温：$temp"
echo "相对湿度：$humidity"
