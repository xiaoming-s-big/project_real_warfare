## Web3 前端开发核心学习模块（扩展版 + RainbowKit 集成）

以下是扩展后的学习模块，我为每个具体章节（从72开始）添加了详细的代码示例和说明。这些示例基于官方文档（Web3.js v1.10.0, ethers.js v6, wagmi v2.x + viem），并针对2025–2026年的现代Web3开发实践进行调整。代码示例假设在浏览器环境中运行（React/Vue等框架中），并包含错误处理和最佳实践。示例中，我使用了ES6+语法和Promise风格（避免回调地狱）。对于生产环境，记得添加环境变量管理API密钥，并使用TypeScript以提升类型安全。

#### 新增：RainbowKit UI 集成

RainbowKit 是 wagmi 的官方 UI 伴侣库，提供开箱即用的连接按钮、模态框（钱包选择、链切换、账户管理等），使 dApp 前端更用户友好。推荐在 wagmi 项目中使用，尤其适合新手避免自定义 UI 的复杂性。  

- ##### 为什么用 RainbowKit：

- 预构建组件，主题自定义，支持多钱包（EIP-6963），与 wagmi/viem 无缝集成。  

- 安装：npm install @rainbow-me/rainbowkit wagmi viem@2.x @tanstack/react-query  
  安装 ： npm install @rainbow-me/rainbowkit wagmi viem@2.x @tanstack/react-query 

- 版本注意：RainbowKit v2.x 与 wagmi v2.x 兼容。
  我将在 wagmi 系列中添加集成示例（扩展 78–80），因为 RainbowKit 专为 wagmi 设计。

#### 基础与工具链

###### 71.Web3 前端基础  

- 理解 DApp 前端架构：前端（React/Vue） + 钱包Provider（MetaMask等） + EVM节点（Infura/Alchemy）。  
- 钱包、Provider、EVM 基础概念：Provider是连接节点的中介；钱包管理私钥和签名；EVM是执行智能合约的虚拟机。  
- MetaMask / WalletConnect 等注入机制：浏览器注入window.ethereum，用于EIP-1193标准。  
- EIP-1193 / EIP-6963 标准简介：EIP-1193定义Provider接口（如request方法）；EIP-6963支持多钱包发现。
  说明：无代码示例，此为基础理论。建议先安装MetaMask扩展并在浏览器控制台测试window.ethereum。

#### Web3.js 系列（传统库，适合理解底层）

###### 72.Web3.js (1)：Provider 类别详解  

- HttpProvider、WebSocketProvider、IpcProvider：Http用于简单查询，无订阅；WebSocket支持实时事件；Ipc仅Node.js本地。  
- 自定义 Provider 与 fallback 机制：使用Alchemy/Infura等远程节点，支持自动重连。  
- EIP-1193 Provider（window.ethereum）适配：浏览器自动注入。
  详细说明：Web3.js的Provider处理JSON-RPC通信。Http不适合dApp实时性；优先WebSocket。自定义选项包括超时和重连。
  代码示例（基本设置Provider）：

javascript

```javascript
const Web3 = require('web3'); // 或 import Web3 from 'web3';

// 浏览器注入Provider (MetaMask)
let provider = window.ethereum ? window.ethereum : null;
if (!provider) {
  // Fallback到远程节点
  provider = new Web3.providers.HttpProvider('https://mainnet.infura.io/v3/YOUR_INFURA_KEY');
}
const web3 = new Web3(provider);

// 高级WebSocket配置（支持重连）
const wsOptions = {
  timeout: 30000,
  reconnect: { auto: true, delay: 5000, maxAttempts: 10 }
};
const wsProvider = new Web3.providers.WebsocketProvider('wss://mainnet.infura.io/ws/v3/YOUR_INFURA_KEY', wsOptions);
web3.setProvider(wsProvider); // 运行时切换

// 测试连接
web3.eth.getBlockNumber().then(console.log).catch(err => console.error('连接失败:', err));
```

说明：如果window.ethereum存在，使用它；否则fallback。setProvider允许热切换。

###### 73.Web3.js (2)：连接钱包  

- 检测 & 请求连接（eth_requestAccounts）：检查并请求用户授权。  
- 监听账户/链切换事件：使用subscribe。  
- 断开连接与错误处理：处理拒绝和网络错误。
  详细说明：连接依赖EIP-1102。requestAccounts弹出钱包提示。事件监听确保UI实时更新。
  代码示例（React组件中连接）：

javascript

```javascript
import Web3 from 'web3';
import { useState, useEffect } from 'react';

const Web3Connect = () => {
  const [account, setAccount] = useState(null);
  const [web3, setWeb3] = useState(null);

  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        setWeb3(web3Instance);

        // 监听事件
        window.ethereum.on('accountsChanged', (accounts) => {
          setAccount(accounts[0] || null);
          console.log('账户变更:', accounts);
        });
        window.ethereum.on('chainChanged', (chainId) => {
          console.log('链ID变更:', chainId);
          window.location.reload(); // 可选刷新
        });
      } else {
        console.error('未检测到钱包');
      }
    };
    initWeb3();
  }, []);

  const connectWallet = async () => {
    if (web3) {
      try {
        const accounts = await web3.eth.requestAccounts();
        setAccount(accounts[0]);
        console.log('已连接:', accounts);
      } catch (err) {
        console.error('连接失败:', err.message); // e.g., 用户拒绝
      }
    }
  };

  return (
    <div>
      <button onClick={connectWallet}>连接钱包</button>
      <p>当前账户: {account || '未连接'}</p>
    </div>
  );
};
```

说明：使用React Hook管理状态。错误处理捕获用户拒绝。

###### 74.Web3.js (3)：合约交互  

- Contract 实例创建：需要ABI和地址。  
- call / sendTransaction：call读；send写。  
  调用/发送事务：调用读；发送写。
- 事件监听（event filter）：实时和历史查询。  
- estimateGas & 错误解析：预估gas避免失败。
  详细说明：Contract封装方法调用。send返回receipt；事件支持filter。
  代码示例（ERC20余额查询和转账）：

javascript

```javascript
const Web3 = require('web3');
const web3 = new Web3(window.ethereum);

// 示例ABI (简化ERC20)
const abi = [
  { "constant": true, "inputs": [{ "name": "_owner", "type": "address" }], "name": "balanceOf", "outputs": [{ "name": "balance", "type": "uint256" }], "type": "function" },
  { "constant": false, "inputs": [{ "name": "_to", "type": "address" }, { "name": "_value", "type": "uint256" }], "name": "transfer", "outputs": [{ "name": "success", "type": "bool" }], "type": "function" },
  { "anonymous": false, "inputs": [{ "indexed": true, "name": "from", "type": "address" }, { "indexed": true, "name": "to", "type": "address" }, { "indexed": false, "name": "value", "type": "uint256" }], "name": "Transfer", "type": "event" }
];
const contractAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7'; // USDT Mainnet

const contract = new web3.eth.Contract(abi, contractAddress);

// 读: 获取余额
async function getBalance(address) {
  try {
    const balance = await contract.methods.balanceOf(address).call();
    console.log('余额:', balance);
  } catch (err) {
    console.error('查询失败:', err);
  }
}

// 写: 转账
async function transfer(to, value, from) {
  try {
    const gasEstimate = await contract.methods.transfer(to, value).estimateGas({ from });
    const tx = await contract.methods.transfer(to, value).send({ from, gas: gasEstimate + 10000 });
    console.log('交易receipt:', tx);
  } catch (err) {
    console.error('转账失败:', err.message); // 解析错误
  }
}

// 事件监听
contract.events.Transfer({
  filter: { from: '0xYourAddress' },
  fromBlock: 'latest'
}).on('data', (event) => console.log('转账事件:', event))
  .on('error', console.error);
```

说明：estimateGas防止out-of-gas。事件on('data')处理新事件。

ethers.js 系列（目前仍最广泛使用的低层库）

###### 75.ethers.js (1)：概况与核心概念  

- ethers v5 / v6 差异：v6更模块化，支持ESM，分离Provider/Signer。  
- Provider、Signer、Wallet 三大核心：Provider读；Signer签；Wallet本地私钥。  
  Provider、Signer、Wallet 三大核心：Provider 读；Signer 签；Wallet 本地私钥。
- 与 Web3.js 的主要对比：ethers更安全（读写分离），TypeScript友好。
  详细说明：ethers v6强调模块化，避免Web3.js的 monolithic设计。适合中级开发者。
  代码示例（基本设置）：

javascript

```javascript
import { ethers } from 'ethers';

// Provider: 连接Infura
const provider = new ethers.JsonRpcProvider('https://mainnet.infura.io/v3/YOUR_INFURA_KEY');

// Signer: 从MetaMask获取
let signer;
if (window.ethereum) {
  const browserProvider = new ethers.BrowserProvider(window.ethereum);
  signer = await browserProvider.getSigner();
} else {
  // 本地Wallet fallback
  const privateKey = '0xYourPrivateKey'; // 测试用
  signer = new ethers.Wallet(privateKey, provider);
}

// 测试: 获取余额
const balance = await provider.getBalance('0xYourAddress');
console.log('余额 (ETH):', ethers.formatEther(balance));

// 比较: ethers更简洁 vs Web3.js的verbose
```

说明：BrowserProvider处理浏览器注入。Wallet用于测试。

###### 76.ethers.js (2)：连接钱包  

- BrowserProvider（推荐用于前端）：处理window.ethereum。  
- 连接 MetaMask / WalletConnect：请求accounts。  
  连接 MetaMask / WalletConnect：请求账户。
- 监听 accountsChanged / chainChanged：使用on。  
  监听 accountsChanged / chainChanged：使用 on。
- getSigner() 与签名相关操作：获取签名者。
  详细说明：连接类似Web3.js，但更安全（Signer隔离）。WalletConnect需额外适配器。
  代码示例（React连接）：

javascript

```javascript
import { ethers } from 'ethers';
import { useState, useEffect } from 'react';

const EthersConnect = () => {
  const [account, setAccount] = useState(null);
  const [provider, setProvider] = useState(null);

  useEffect(() => {
    if (window.ethereum) {
      const prov = new ethers.BrowserProvider(window.ethereum);
      setProvider(prov);

      // 监听
      window.ethereum.on('accountsChanged', async () => {
        const signer = await prov.getSigner();
        setAccount(await signer.getAddress());
      });
      window.ethereum.on('chainChanged', () => window.location.reload());
    }
  }, []);

  const connect = async () => {
    if (provider) {
      try {
        const signer = await provider.getSigner();
        setAccount(await signer.getAddress());
      } catch (err) {
        console.error('连接失败:', err);
      }
    }
  };

  return (
    <div>
      <button onClick={connect}>连接</button>
      <p>账户: {account}</p>
    </div>
  );
};
```

说明：getSigner()隐式请求连接。错误包括用户取消。

###### 77.ethers.js (3)：合约交互  

- Contract 类使用（ABI + 地址）：创建实例。  
- read（callStatic） / write（populateTransaction）：read无gas；write需签名。  
  读（callStatic） / 写（populateTransaction）：读无 gas；写需签名。
- 接口编码 / 解码：utils提供。  
- 事件监听（on / once / queryFilter）：实时和历史。  
- 多链 / ENS 支持：内置。
  详细说明：Contract方法自动代理。write返回tx；wait()确认。
  代码示例（ERC20交互）：

javascript

```javascript
import { ethers } from 'ethers';

const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

// ABI简化
const abi = ['function balanceOf(address) view returns (uint)', 'function transfer(address to, uint amount)', 'event Transfer(address from, address to, uint value)'];
const contract = new ethers.Contract('0xdAC17F958D2ee523a2206206994597C13D831ec7', abi, signer);

// 读
const balance = await contract.balanceOf(await signer.getAddress());
console.log('余额:', balance.toString());

// 写
try {
  const tx = await contract.transfer('0xRecipient', ethers.parseUnits('1.0', 6)); // USDT 6 decimals
  const receipt = await tx.wait();
  console.log('receipt:', receipt);
} catch (err) {
  console.error('失败:', err);
}

// 事件
contract.on('Transfer', (from, to, value) => console.log(`从 ${from} 到 ${to}: ${value}`));

// 历史查询
const events = await contract.queryFilter('Transfer', -100); // 最近100块
console.log(events);
```

说明：parseUnits处理decimals。queryFilter高效查询。

#### wagmi 系列（现代 React 推荐方案，基于 viem）

###### 78.wagmi (1)：快速入门  

- wagmi + viem + React 的现代 Web3 技术栈：wagmi封装hooks；viem底层交互。  

- 为什么推荐 wagmi（对比 ethers.js / web3.js）：hooks式，自动重连，类型安全。  

- 安装 & 配置 WagmiConfig / WagmiProvider：需

  @tanstack

  /react-query。  

  安装和配置 WagmiConfig / WagmiProvider：需 

  @tanstack

  /react-query。

- 支持的连接器（injected、walletConnect、coinbase 等）：内置多种。
  详细说明：wagmi简化React集成。createConfig定义链和transport。
  代码示例（App配置 + RainbowKit 集成）：

javascript

```javascript
import { createConfig, http } from 'wagmi';
import { mainnet, sepolia } from 'wagmi/chains';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider } from 'wagmi';
import { RainbowKitProvider, getDefaultConfig } from '@rainbow-me/rainbowkit'; // 新增 RainbowKit

// 使用 getDefaultConfig 简化配置（RainbowKit 推荐）
const config = getDefaultConfig({
  appName: 'My DApp',
  projectId: 'YOUR_WALLETCONNECT_PROJECT_ID', // WalletConnect Cloud ID
  chains: [mainnet, sepolia],
  transports: { [mainnet.id]: http(), [sepolia.id]: http() },
});

const queryClient = new QueryClient();

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider> {/* RainbowKit 包裹，提供主题和模态 */}
          {/* 子组件，如路由 */}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
```

说明：getDefaultConfig 自动处理连接器（injected, walletConnect 等）。RainbowKitProvider 启用 UI 组件。获取 WalletConnect ID 从 cloud.walletconnect.com。
说明 ：getDefaultConfig 自动处理连接器（注入、walletConnect 等）。RainbowKitProvider 启用 UI 组件。从 cloud.walletconnect.com 获取 WalletConnect ID。

###### 79.wagmi (2)：连接钱包  

- useConnect / useAccount / useDisconnect：连接、状态、断开。  
- useNetwork / useSwitchNetwork：链管理。  
- <ConnectButton /> 或自定义连接按钮：RainbowKit提供UI。  
- EIP-6963 多钱包支持：自动发现。
  详细说明：hooks响应式。useAccount返回address/status。RainbowKit 的 <ConnectButton /> 替换自定义按钮，提供完整模态（钱包列表、账户详情、断开等）。
  代码示例（连接组件 + RainbowKit UI）：

javascript

```javascript
import { useConnect, useAccount, useDisconnect, useNetwork, useSwitchNetwork } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit'; // RainbowKit 按钮

const ConnectWallet = () => {
  const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();
  const { chain } = useNetwork();
  const { switchNetwork } = useSwitchNetwork();

  return (
    <div>
      {/* RainbowKit 按钮：自动处理连接/断开/账户显示 */}
      <ConnectButton 
        showBalance={{ smallScreen: true, largeScreen: false }} // 可选：小屏显示余额
        chainStatus={{ smallScreen: 'icon', largeScreen: 'full' }} // 链状态显示
        accountStatus={{ smallScreen: 'avatar', largeScreen: 'full' }} // 账户显示
      />
      {isConnected && (
        <>
          <p>地址: {address}</p>
          <p>链: {chain?.name}</p>
          <button onClick={() => switchNetwork(1)}>切换到Mainnet</button> // ID 1
          <button onClick={disconnect}>断开</button> // 可选自定义断开
        </>
      )}
    </div>
  );
};
```

说明：<ConnectButton /> 是即插即用组件，支持自定义主题（通过 RainbowKitProvider 的 theme prop）。无需手动 useConnect，除非自定义逻辑。RainbowKit 自动处理多钱包和链切换模态。

###### 80.wagmi (3)：合约交互  

- useReadContract / useWriteContract / useWaitForTransactionReceipt：读/写/等待。  
- useContractRead / useContractWrite（旧版 hooks）：已弃用，优先新版。  
  useContractRead / useContractWrite（旧版钩子）：已弃用，优先新版。
- useContractEvent（事件监听）：实时。  
- 类型安全的 ABI（配合 typechain / abi-type）：生成TS类型。  
- 自动 watch / refetch 机制：wagmi自动轮询。
  详细说明：hooks集成查询缓存。watch启用实时更新。RainbowKit 不直接影响合约交互，但可结合 UI（如在模态中显示交易状态）。
  代码示例（ERC20交互 + RainbowKit 集成提示）：

javascript

```javascript
import { useReadContract, useWriteContract, useContractEvent, useWaitForTransactionReceipt } from 'wagmi';
import { parseAbi } from 'viem';
import { ConnectButton } from '@rainbow-me/rainbowkit'; // 可在交互前检查连接

const abi = parseAbi(['function balanceOf(address) view returns (uint)', 'function transfer(address to, uint amount)', 'event Transfer(address from, address to, uint value)']);
const contractConfig = { address: '0xdAC17F958D2ee523a2206206994597C13D831ec7', abi };

const ContractInteract = () => {
  const { data: balance } = useReadContract({ ...contractConfig, functionName: 'balanceOf', args: ['0xYourAddress'], watch: true }); // 自动refetch

  const { writeContract, data: hash } = useWriteContract();
  const { data: receipt } = useWaitForTransactionReceipt({ hash });

  useContractEvent({ ...contractConfig, eventName: 'Transfer', listener: (logs) => console.log(logs) });

  const transfer = () => writeContract({ ...contractConfig, functionName: 'transfer', args: ['0xRecipient', 1000000n] }); // BigInt

  return (
    <div>
      <ConnectButton /> {/* 确保连接后交互 */}
      <p>余额: {balance?.toString()}</p>
      <button onClick={transfer}>转账</button>
      {receipt && <p>Receipt: {receipt.transactionHash}</p>}
    </div>
  );
};
```

说明：parseAbi确保类型。useWaitForTransactionReceipt确认tx。watch启用轮询。在实际 dApp 中，可用 RainbowKit 的模态显示交易 pending/成功状态（通过自定义主题或 hooks 集成）。

##### 推荐学习顺序（2026 年视角）

1. 先把 71 搞懂（最基础的概念）
2. 建议 75–77 ethers.js 完整走一遍（理解底层原理最清楚）
3. 再学 78–80 wagmi（实际项目中 90%+ 会用这个），并集成 RainbowKit 以提升 UI 体验
4. web3.js 可以作为了解历史与原理的补充（72–74），现在新项目极少直接用

如果需要更多示例（如 RainbowKit 自定义主题或多链配置），或扩展到其他库（如 useDApp），告诉我

![b9d2e11a9805af085e32b8fca6460814](C:\Users\Administrator\xwechat_files\wxid_g358hdvdu6h922_875d\temp\RWTemp\2026-01\1ae924f77d712c6376d324cc92eb2bd7\b9d2e11a9805af085e32b8fca6460814.png)

