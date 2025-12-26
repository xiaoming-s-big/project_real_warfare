"""
Description:
通过实践理解区块链的工作量证明及链式结构。

题目#1
用自己熟悉的语言模拟实现最小的区块链， 包含两个功能：

POW 证明出块，难度为 4 个 0 开头
每个区块包含previous_hash 让区块串联起来。  

如下是一个参考区块结构：

block = {
'index': 1,
'timestamp': 1506057125,
'transactions': [
    { 'sender': "xxx", 
    'recipient': "xxx", 
    'amount': 5, } ], 
'proof': 324984774000,
'previous_hash': "xxxx"
}

请提交完成的 github 代码仓库链接， 在 Readme 中包含运行说明及运行日志或截图。
"""

package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"
)

// 区块结构
type Block struct {
	Index         int       `json:"index"`
	Timestamp     int64     `json:"timestamp"`
	Transactions  []Transaction `json:"transactions"`
	Proof         int       `json:"proof"`
	PreviousHash  string    `json:"previous_hash"`
}

// 交易结构
type Transaction struct {
	Sender    string  `json:"sender"`
	Recipient string  `json:"recipient"`
	Amount    float64 `json:"amount"`
}

// 生成区块哈希
func hashBlock(block Block) string {
	blockJson, _ := json.Marshal(block)
	hash := sha256.Sum256(blockJson)
	return hex.EncodeToString(hash[:])
}

// POW工作量证明
func proofOfWork(lastProof int) int {
	proof := 0
	for !validProof(lastProof, proof) {
		proof++
	}
	return proof
}

// 验证POW
func validProof(lastProof, proof int) bool {
	guess := fmt.Sprintf("%d%d", lastProof, proof)
	hash := sha256.Sum256([]byte(guess))
	hashStr := hex.EncodeToString(hash[:])
	return hashStr[:4] == "0000"
}

func main() {
	// 创世区块
	genesisBlock := Block{
		Index:        1,
		Timestamp:    time.Now().Unix(),
		Transactions: []Transaction{},
		Proof:        100,
		PreviousHash: "0",
	}

	// 测试POW
	proof := proofOfWork(100)
	fmt.Printf("找到的Proof值：%d\n", proof)
	fmt.Printf("创世区块哈希：%s\n", hashBlock(genesisBlock))
}