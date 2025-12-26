Description:

通过几道填空题理解 Gas 机制
/**
先明确以太坊 EIP-1559 后的核心 Gas 概念（必备基础）
在解答前，先记住这几个核心定义和公式，所有计算都基于此：
    1 Base Fee（基础费用）：以太坊网络自动计算的基础手续费，会燃烧（销毁），不进入矿工口袋。
    2 Max Priority Fee（最大优先费）：用户愿意支付给矿工的小费，激励矿工打包交易，全部归矿工。
    3 Max Fee（最大总费用）：用户愿意为每单位 Gas 支付的最高总费用（Base Fee + 优先费），
      公式：Max Fee ≥ Base Fee + Max Priority Fee（否则交易可能不被打包）。
    4 实际每单位 Gas 费用：min(Max Fee, Base Fee + Max Priority Fee) → 
      简化为 Base Fee + 实际优先费（实际优先费≤Max Priority Fee）。
    5 单位换算：1 GWei = 10^9 Wei（这里题目统一用 GWei，无需换算）。
 */
//题目#1
在以太坊上,用户发起一笔交易 设置了GasLimit 为 10000, 
Max Fee 为 10 GWei, Max priority fee 为 1 GWei , 
为此用户应该在钱包账号里多少 GWei 的余额？

核心逻辑:用户需要预留的余额是「最大可能支付的总费用」,即 GasLimit * Max Fee(因为 Max Fee 是每单位 Gas 
愿意支付的最高费用,GasLimit 是最多愿意消耗的 Gas 数量)。

计算过程:10000 * 10 = 100000 GWei
答案:100000 GWei

//题目#2
在以太坊上,用户发起一笔交易 设置了 GasLimit 为 10000, Max Fee 为 10 GWei, 
Max priority Fee 为 1 GWei,在打包时,Base Fee 为 5 GWei, 实际消耗的Gas为 5000, 
那么矿工(验证者)拿到的手续费是多少 GWei ?

核心逻辑:矿工仅能拿到「优先费」部分,优先费的计算是:实际优先费 * 实际消耗Gas。
这里Base Fee + Max Priority Fee = 5+1=6 ≤ Max Fee=10,所以实际优先费 = Max Priority Fee=1 GWei。
计算过程:5000 * 1 = 5000 GWei
答案:5000 GWei

//题目#3
在以太坊上,用户发起一笔交易 设置了 GasLimit 为 10000, Max Fee 为 10 GWei, 
Max priority Fee 为 1 GWei,在打包时,Base Fee 为 5 GWei, 实际消耗的Gas为 5000, 
那么用户需要支付的的手续费是多少 GWei ?

核心逻辑:用户支付的总费用 = 实际消耗Gas * (Base Fee + 实际优先费)
(总费用 = 燃烧的 Base Fee 部分 + 矿工的优先费部分)。
计算过程:实际每单位 Gas 费用 = 5(Base Fee) + 1(优先费)= 6 GWei总费用 = 5000 * 6 = 30000 GWei

答案:30000 GWei

//题目#4
在以太坊上,用户发起一笔交易 设置了 GasLimit 为 10000, 
Max Fee 为 10 GWei, Max priority Fee 为 1 GWei,在打包时,
Base Fee 为 5 GWei, 实际消耗的 Gas 为 5000, 那么燃烧掉的 Eth 数量是多少 GWei ?

核心逻辑:燃烧的部分仅为 Base Fee * 实际消耗 Gas(Base Fee 全部销毁,不进入任何地址)。
计算过程:5000 * 5 = 25000 GWei
答案:25000 GWei

总结:
钱包预留余额:GasLimit * Max Fee(覆盖最大可能支出),本题为 100000 GWei。
矿工收益:实际消耗Gas * 实际优先费(仅优先费部分),本题为 5000 GWei。
用户总支付:实际消耗Gas * (Base Fee + 实际优先费),本题为 30000 GWei。
燃烧金额:实际消耗Gas * Base Fee(仅基础费部分),本题为 25000 GWei。