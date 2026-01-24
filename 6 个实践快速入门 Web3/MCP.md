## ✅ **但我已经有这些内置功能**

虽然 MCP 服务器未启动，但我有强大的**原生工具集**：

\###📁 **文件操作**

- `read_file` - 读取文件
- `write_file` - 写入文件
- `edit_file` - 编辑文件（SEARCH/REPLACE）
- `list_files` - 列出目录
- `read_many_files` - 批量读取
- `search_files` - 正则搜索

### 🏗️ **项目创建**

- ```
  create_workspace
  ```

   

  \- 创建项目模板

  - ✅ Solidity 智能合约（Foundry）
  - ✅ React 前端（Vite + TypeScript）
  - ✅ 全栈 DApp（React + Solidity + Wagmi）
  - ✅ Cairo/Starknet DApp
  - ✅ Move/Sui DApp
  - ✅ Solana DApp

\###🌐 **网络功能**

- `web_search` - 实时网络搜索
- `web_fetch` - 获取网页内容

### 📚 **知识检索**

- ```
  rag_retrieve
  ```

   

  \- 检索知识库

  - ✅ `nora`索引（Web3 文档）
  - ✅ `web3-programming` 索引

### 🔧 **MCP 集成**

- `use_mcp_tool` - 调用 MCP 服务器工具（需配置）
- 

###### 提示词相关：

完成前端界面的搭建,并给出一个部署、配置的指南文档(包含本地和测试网)





开发一个基于React框架的区块链连接应用DApp，要求实现以下功能：

1. 支持以太坊和Solana双链连接：
   - 对于以太坊链：使用Viem/Wagmi库实现钱包连接、交易签名和合约交互
   - 对于Solana链：使用web3.js库实现钱包连接、交易签名和程序调用

2. 技术要求：
   - 使用React 18+版本构建前端界面
   - 实现响应式设计，适配桌面和移动端
   - 包含完整的错误处理机制
   - 支持主流浏览器钱包（如MetaMask、Phantom等）

3. 核心功能实现：
   - 钱包连接/断开功能
   - 账户余额查询
   - 交易历史展示
   - 基本的代币转账功能
   - 链切换功能（以太坊/Solana）

4. 开发规范：
   - 使用TypeScript进行开发
   - 遵循ESLint代码规范
   - 包含完整的单元测试
   - 提供清晰的文档注释

5. 性能要求：
   - 页面加载时间控制在3秒内
   - 交易确认反馈时间不超过15秒
   - 内存占用优化

6. 安全要求：
   - 实现完整的钱包连接状态管理
   - 敏感操作需要用户二次确认
   - 私钥/助记词等敏感信息不得存储在本地