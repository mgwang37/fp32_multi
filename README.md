# FP32Multi
符合IEEE-754标准fp32浮点乘法器(四拍流水)
## 包含仿真环境
cd fp32_multi
source setup.bash
cd run
make
./smoke                     ;冒烟测试
./all                       ;遍历测试
./debug   80000000 80000000 ;调试 输入两个浮点数的16进制数
