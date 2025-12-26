/* 
实战 1 ： 编写Bank，通过实战理解合约账号、并能运用合约接收 ETH，
掌握 receive/fallfack函数的使用，payable 使用、及从合约里面转出 ETH，
以及映射和数组的使用。
Description:
该挑战用来理解合约账号、合约如何接收 ETH，receive/fallfack函数的使用，
理解 payable，如何从合约里面转出 ETH，以及映射和数组的使用。
*/

/**
编写一个 Bank 合约，实现功能：

可以通过 Metamask 等钱包直接给 Bank 合约地址存款
在 Bank 合约记录每个地址的存款金额
编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
用数组记录存款金额的前 3 名用户 
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入OpenZeppelin的Ownable合约，实现管理员权限控制
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Bank
 * @dev 实现存款、管理员提现、存款前三榜单功能的合约
 */
contract Bank is Ownable {
    // ======== 状态变量 ========
    // 记录每个地址的存款余额 (地址 => 余额，单位：wei)
    mapping(address => uint256) public userBalances;

    // 存款金额前三的用户（按余额降序排列，最多3个）
    address[] public top3Depositors;

    // ======== 事件 ========
    // 存款事件：记录存款地址、金额、当前余额
    event Deposited(address indexed user, uint256 amount, uint256 newBalance);
    // 提现事件：记录管理员、提现金额、合约剩余余额
    event Withdrawn(
        address indexed owner,
        uint256 amount,
        uint256 remainingBalance
    );

    // ======== 构造函数 ========
    // 部署合约时，将部署者设为管理员（Ownable默认实现）
    constructor() Ownable(msg.sender) {}

    // ======== 核心功能 ========
    /**
     * @dev 接收ETH的回退函数，支持钱包直接向合约地址转账（无需调用方法）
     * 自动触发存款逻辑，记录余额并更新前三榜单
     */
    receive() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        // 1. 更新用户余额
        userBalances[msg.sender] += msg.value;

        // 2. 更新存款前三榜单
        updateTop3Depositors(msg.sender);

        // 3. 触发存款事件
        emit Deposited(msg.sender, msg.value, userBalances[msg.sender]);
    }

    /**
     * @dev 管理员提现方法：仅合约所有者可提取合约内所有ETH
     * @param to 提现接收地址（建议设为管理员地址）
     */
    function withdraw(address payable to) external onlyOwner {
        require(to != address(0), "Invalid recipient address");
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");

        // 安全提现：使用call避免重入攻击（Solidity 0.8+推荐方式）
        (bool success, ) = to.call{value: contractBalance}("");
        require(success, "Withdrawal failed");

        // 触发提现事件
        emit Withdrawn(msg.sender, contractBalance, address(this).balance);
    }

    // ======== 辅助函数 ========
    /**
     * @dev 更新存款前三的用户榜单
     * @param user 刚存款的用户地址
     */
    function updateTop3Depositors(address user) internal {
        // 1. 检查用户是否已在前三列表中
        bool isInTop3 = false;
        uint256 userBalance = userBalances[user];
        for (uint256 i = 0; i < top3Depositors.length; i++) {
            if (top3Depositors[i] == user) {
                isInTop3 = true;
                break;
            }
        }

        // 2. 若不在前三，且列表未满（<3），直接加入
        if (!isInTop3 && top3Depositors.length < 3) {
            top3Depositors.push(user);
        }
        // 3. 若列表已满，检查用户余额是否超过当前最后一名
        else if (!isInTop3 && userBalance > userBalances[top3Depositors[2]]) {
            top3Depositors[2] = user;
        }

        // 4. 对前三列表按余额降序排序
        sortTop3Depositors();
    }

    /**
     * @dev 对前三用户列表按余额降序排序
     */
    function sortTop3Depositors() internal {
        // 简单冒泡排序，适配最多3个元素的场景
        for (uint256 i = 0; i < top3Depositors.length; i++) {
            for (uint256 j = i + 1; j < top3Depositors.length; j++) {
                if (
                    userBalances[top3Depositors[j]] >
                    userBalances[top3Depositors[i]]
                ) {
                    (top3Depositors[i], top3Depositors[j]) = (
                        top3Depositors[j],
                        top3Depositors[i]
                    );
                }
            }
        }
    }

    /**
     * @dev 获取存款前三的用户列表（含余额），方便前端展示
     * @return 地址数组、余额数组（一一对应）
     */
    function getTop3Depositors()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256[] memory balances = new uint256[](top3Depositors.length);
        for (uint256 i = 0; i < top3Depositors.length; i++) {
            balances[i] = userBalances[top3Depositors[i]];
        }
        return (top3Depositors, balances);
    }

    /**
     * @dev 获取合约当前总余额
     * @return 合约ETH余额（wei）
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
