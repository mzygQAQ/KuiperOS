# KuiperOS
KuiperOS是一个轻量级的osKernel. 仅用于学习计算机组成原理和操作系统内幕。

<br/>
1. 低特权级访问高特权级别可以使用门， 但高特权级别访问低特权级别不能使用门，必须巧妙的使用retf </br>
2. 数据段规则 cpl <= dpl && rpl <= dpl
3. 栈段规则  cpl == rpl && cpl == dpl