"""
Description:
编写程序,获得满足某条件的 Hash 值的随机数, 理解非对称加密[RSA]签名与验证。表达式： POW + RSA 签名。

关键概念解析
1 非对称加密核心：
    私钥：唯一且保密,只有持有者能生成有效签名,相当于 “数字签名章”；
    公钥：公开可分发,任何人都能用它验证签名是否由对应私钥生成；
    防篡改：数据一旦被修改,公钥验证签名必然失败,无法伪造。
2 签名与加密的区别：
    签名：私钥→签名（证明 “是我发的”）,公钥→验签（证明 “没被改”）；
    加密：公钥→加密（只有私钥能解）,私钥→解密（保证数据私密）。
3 POW+RSA 的意义：
    POW 保证内容是 “通过算力找到的有效内容”；
    RSA 签名保证内容是 “特定私钥持有者发布的,且未被篡改”。
*/

题目#1
实践 POW, 编写程序(编程语言不限）用自己的昵称 + nonce,不断修改nonce 进行 sha256 Hash 运算:

#直到满足 4 个 0 开头的哈希值,打印出花费的时间、Hash 的内容及Hash值。
#再次运算直到满足 5 个 0 开头的哈希值,打印出花费的时间、Hash 的内容及Hash值。
#提交程序你的 Github 链接 
"""

# import hashlib
# import time

# def mine_pow(nickname: str, target_zeros: int) -> tuple[float, str, str]:
#     """
#     执行POW挖矿:找到昵称+nonce的SHA256哈希以指定数量0开头的结果
#     :param nickname: 自定义昵称
#     :param target_zeros: 哈希前缀需要的0的个数
#     :return: (耗时(秒), 哈希内容(昵称+nonce), 哈希值)
#     """
#     nonce = 0  # 初始随机数,从0开始递增
#     target_prefix = "0" * target_zeros  # 目标前缀(如4个0则为"0000"）
#     start_time = time.time()  # 记录开始时间

#     # 循环计算哈希,直到满足条件
#     while True:
#         # 拼接哈希内容:昵称 + nonce(转为字符串）
#         hash_content = f"{nickname}{nonce}"
#         # 计算SHA256哈希(utf-8编码,转16进制字符串）
#         hash_result = hashlib.sha256(hash_content.encode("utf-8")).hexdigest()
        
#         # 检查哈希前缀是否满足条件
#         if hash_result.startswith(target_prefix):
#             end_time = time.time()
#             elapsed_time = end_time - start_time  # 计算耗时
#             return (elapsed_time, hash_content, hash_result)
        
#         # 不满足则nonce+1,继续循环
#         nonce += 1

# if __name__ == "__main__":
#     # 替换为你自己的昵称
#     MY_NICKNAME = "编程学习助手"
    
#     # 第一步:找4个0开头的哈希
#     print("===== 开始POW运算(4个0前缀）=====")
#     time_4, content_4, hash_4 = mine_pow(MY_NICKNAME, 3)
#     print(f"耗时:{time_4:.4f} 秒")
#     print(f"哈希内容:{content_4}")
#     print(f"哈希值:{hash_4}\n")

#     # 第二步:找5个0开头的哈希
#     print("===== 开始POW运算(5个0前缀）=====")
#     time_5, content_5, hash_5 = mine_pow(MY_NICKNAME, 5)
#     print(f"耗时:{time_5:.4f} 秒")
#     print(f"哈希内容:{content_5}")
#     print(f"哈希值:{hash_5}")

"""
题目#2
实践非对称加密 RSA(编程语言不限):

1 先生成一个公私钥对
2 用私钥对符合 POW 4 个 0 开头的哈希值的 “昵称 + nonce” 进行私钥签名
3 用公钥验证
提交程序你的 Github 链接

"""
import hashlib
import time
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

# ====================== 1. POW核心函数 ======================
def mine_pow(nickname: str, target_zeros: int) -> tuple[float, str, str]:
    """
    执行POW挖矿:找到昵称+nonce的SHA256哈希以指定数量0开头的结果
    :param nickname: 自定义昵称
    :param target_zeros: 哈希前缀需要的0的个数
    :return: (耗时(秒), 哈希内容(昵称+nonce), 哈希值)
    """
    nonce = 0
    target_prefix = "0" * target_zeros
    start_time = time.time()

    while True:
        hash_content = f"{nickname}{nonce}"
        hash_result = hashlib.sha256(hash_content.encode("utf-8")).hexdigest()
        
        if hash_result.startswith(target_prefix):
            end_time = time.time()
            elapsed_time = end_time - start_time
            return (elapsed_time, hash_content, hash_result)
        
        nonce += 1

# ====================== 2. RSA密钥生成/签名/验证 ======================
def generate_rsa_key_pair() -> tuple[rsa.RSAPrivateKey, rsa.RSAPublicKey]:
    """生成RSA公私钥对(2048位,非对称加密常用长度）"""
    # 生成私钥:2048位密钥长度,公钥指数65537(行业标准）
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    # 从私钥导出公钥
    public_key = private_key.public_key()
    return private_key, public_key

def rsa_sign(private_key: rsa.RSAPrivateKey, data: str) -> bytes:
    """用RSA私钥对数据签名"""
    # 签名算法:PKCS1v15填充 + SHA256哈希(常用组合）
    signature = private_key.sign(
        data.encode("utf-8"),  # 待签名数据转字节流
        padding.PKCS1v15(),
        hashes.SHA256()
    )
    return signature

def rsa_verify(public_key: rsa.RSAPublicKey, data: str, signature: bytes) -> bool:
    """用RSA公钥验证签名是否有效"""
    try:
        # 验证逻辑:用公钥解密签名,对比数据的哈希值
        public_key.verify(
            signature,
            data.encode("utf-8"),
            padding.PKCS1v15(),
            hashes.SHA256()
        )
        return True  # 签名有效
    except Exception:
        return False  # 签名无效(数据篡改/私钥错误）

# ====================== 3. 主程序:整合POW + RSA ======================
if __name__ == "__main__":
    # 自定义昵称
    MY_NICKNAME = "编程学习助手"
    
    # 第一步:执行POW,找到4个0开头哈希对应的内容
    print("===== 开始POW运算(4个0前缀）=====")
    pow_time, pow_content, pow_hash = mine_pow(MY_NICKNAME, 4)
    print(f"POW耗时:{pow_time:.4f} 秒")
    print(f"符合条件的内容(昵称+nonce):{pow_content}")
    print(f"对应的SHA256哈希值:{pow_hash}\n")

    # 第二步:生成RSA公私钥对
    print("===== 生成RSA公私钥对 =====")
    private_key, public_key = generate_rsa_key_pair()
    # 可选:将密钥保存为PEM格式字符串(方便查看/存储）
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    public_pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    print("私钥(PEM格式):\n", private_pem.decode("utf-8")[:100] + "...")  # 截断显示
    print("公钥(PEM格式):\n", public_pem.decode("utf-8")[:100] + "...\n")

    # 第三步:用私钥对POW结果签名
    print("===== 用私钥签名POW内容 =====")
    signature = rsa_sign(private_key, pow_content)
    print(f"签名结果(十六进制):{signature.hex()[:50]}...\n")  # 截断显示

    # 第四步:用公钥验证签名
    print("===== 用公钥验证签名 =====")
    verify_result = rsa_verify(public_key, pow_content, signature)
    print(f"签名验证结果:{'有效' if verify_result else '无效'}")

    # 测试:篡改数据后验证(预期失败）
    tampered_content = pow_content + "123"  # 篡改内容
    tampered_verify = rsa_verify(public_key, tampered_content, signature)
    print(f"篡改数据后的验证结果:{'有效' if tampered_verify else '无效'}")