# KuiperOS
KuiperOS是一个轻量级的osKernel. 仅用于学习计算机组成原理和操作系统内幕。

<br/>
1. 低特权级访问高特权级别可以使用门， 但高特权级别访问低特权级别不能使用门，必须巧妙的使用retf </br>
2. 数据段规则 cpl <= dpl && rpl <= dpl</br>
3. 栈段规则  cpl == rpl && cpl == dpl</br>

在不借助门描述符的情况下，</br>
非一致性代码段，代码段之间只能平移转移 cpl==dpl && rpl <= dpl</br>
一致性代码段，支持地特权级向高特权级代码的转移（cpl > dpl）,虽然可以成功转移，但是当前特权级不变</br>

降特权级retf时, 目标代码段特权级与目标栈段特权级必须完全相同 ss.rpl == cs.rpl && ss.dpl == cs.rpl

