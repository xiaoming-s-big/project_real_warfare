// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract SimpleAuction {
    // 拍卖的参数。时间可以是绝对的 unix 时间戳（自 1970-01-01 起的秒数）或以秒为单位的时间段。
    address payable public beneficiary;
    uint public auctionEndTime;

    // 拍卖的当前状态。
    address public highestBidder;
    uint public highestBid;

    // 允许取回的先前出价
    mapping(address => uint) pendingReturns;

    // 在结束时设置为 true，禁止任何更改。
    // 默认初始化为 `false`。
    bool ended;

    // 变更触发的事件。
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Errors 用来定义失败

    // 三斜杠注释是所谓的 natspec 注释。
    // 当用户被要求确认交易时将显示它们，或者当显示错误时。

    /// 拍卖已经结束。
    error AuctionAlreadyEnded();
    /// 已经有更高或相等的出价。
    error BidNotHighEnough(uint highestBid);
    /// 拍卖尚未结束。
    error AuctionNotYetEnded();
    /// 函数 auctionEnd 已经被调用。
    error AuctionEndAlreadyCalled();

    /// 创建一个简单的拍卖，拍卖时间为 `biddingTime`秒，代表受益人地址 `beneficiaryAddress`。
    constructor(uint biddingTime, address payable beneficiaryAddress) {
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }

    /// 在拍卖中出价，出价的值与此交易一起发送。
    /// 该值仅在拍卖未获胜时退款。
    function bid() external payable {
        // 不需要参数，所有信息已经是交易的一部分。
        // 关键字 payable 是必需的，以便函数能够接收以太。

        // 如果拍卖时间已过，则撤销调用。
        if (block.timestamp > auctionEndTime) revert AuctionAlreadyEnded();

        // 如果出价不高，则将以太币退回（撤销语句将撤销此函数执行中的所有更改，包括它已接收以太币）。
        if (msg.value <= highestBid) revert BidNotHighEnough(highestBid);

        if (highestBid != 0) {
            // 通过简单使用 highestBidder.send(highestBid) 退回以太币是一个安全风险，因为它可能会执行一个不受信任的合约。
            // 让接收者自行提取他们的以太币总是更安全。
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// 取回出价（当该出价已被超越）
    function withdraw() external returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // 将其设置为零很重要，因为接收者可以在 `send` 返回之前再次调用此函数作为接收调用的一部分。
            pendingReturns[msg.sender] = 0;

            // msg.sender 不是 `address payable` 类型，必须显式转换为 `payable(msg.sender)` 以便使用成员函数 `send()`。
            if (!payable(msg.sender).send(amount)) {
                // 这里不需要调用 throw，只需重置未付款
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// 结束拍卖并将最高出价发送给受益人。
    function auctionEnd() external {
        // 这是一个好的指导原则，将与其他合约交互的函数（即它们调用函数或发送以太）结构化为三个阶段：
        // 1. 检查条件
        // 2. 执行操作（可能更改条件）
        // 3. 与其他合约交互
        // 如果这些阶段混合在一起，其他合约可能会回调当前合约并修改状态或导致效果（以太支付）被多次执行。
        // 如果内部调用的函数包括与外部合约的交互，它们也必须被视为与外部合约的交互。

        // 1. 条件
        if (block.timestamp < auctionEndTime) revert AuctionNotYetEnded();
        if (ended) revert AuctionEndAlreadyCalled();

        // 2. 生效
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3. 交互
        beneficiary.transfer(highestBid);
    }
}

/**
测试核心要点总结
1. 测试维度（必覆盖）
时间约束：拍卖未结束 / 结束后的操作权限（核心依赖 block.timestamp）；
资金安全：出价金额的存储、撤回、转账是否准确（无丢失 / 多转）；
权限与异常：非法操作（出价不足、重复结束拍卖）是否触发指定错误；
事件完整性：关键操作（出价、结束拍卖）是否触发对应事件。
 */
