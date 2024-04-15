# VFANS-IC


VFANS SBT is a smart contract that utilizes the ICRC-7 standard for NFTs. It's designed to store user asset information on the VFANS platform. This contract specifically disallows transfers of the NFTs, prioritizing the secure storage of user asset data on the blockchain.

Key functionalities:

1. Acquiring User Internet Identity via Oauth2 Authorization: This function enables the contract to retrieve relevant information from the user's authorized Internet Identity and link it to their VFANS account.

2. Synchronizing SBT and VFANS Account Information: By leveraging Internet Computer Http Outcalls and scheduled tasks, the contract can periodically obtain user asset information from the VFANS platform and synchronize it with the SBT.

3. Built-in Billing Functionality: This feature allows users to view their current canister's cycles balance and daily cycles consumption in real-time, facilitating management of their account resources.



VFANS SBT 基于ICRC-7的NFT 智能合约, 包含用户在Vfans上的资产信息。 SBT不支持转让。 

1. 通过Oauth2的授权方法获取用户Internet Identity, 从而绑定VFANS的off-chain账户信息。
2. 通过 Internet Compter Http Outcalls 和定时任务功能，同步SBT和VFANS账户的信息。
3. 提供了内置账单功能，可以实时查看当前cansiter的cycles余额和每日cycles消耗。





## 介绍

本项目链接了链上与链下。通过使用Motoko 语言来编写智能合约。基于Motoko的特性实现数据链上的永久存储。

- 铸币流程图

![image](https://github.com/VFans-org/VFANS-IC-Public/assets/107297097/7473330a-a415-4386-bd40-4392a184d1ce)


  - 同步数据流程

![image](https://github.com/VFans-org/VFANS-IC-Public/assets/107297097/1e4e366a-cb2a-40f6-96a6-1ee65a03d394)



## 部署流程

### 部署环境

- dfx sdk
- Npm

开始部署

A step-by-step guide to installing the project, including necessary configuration etc.

```bash
$ git clone https://github.com/VFans-org/VFANS-IC-Public
$ cd VFANS-IC-Public
$ npm install
# 本地部署
$ sh deploy-local all 
# 主网部署 需要cycles
$ sh deploy
```

## 前端页面

https://5tqw5-6yaaa-aaaal-ai4va-cai.icp0.io/

### 示例1 通过ic_account_id 查看NFT信息

```bash
$ dfx canister call nft_backend queryNfts '("your ic_account_id")'
```

### 示例2 查看当前Cycle 余额

```bash
dfx canister call nft_backend query_balance '()'
```

### 示例3 查看账单

```ba
dfx canister call nft_backend query_cycles_ledger '()'
```

## 文档

- 定执行定时任务

```shell
// timerId 为定时任务ID   seconds fiftySecond 指定定时任务执行时间间隔 outCall 定时任务执行方法回调
timerId := recurringTimer<system>(#seconds fiftySecond, outCall);
```

- 执行http out call

```shell
  // 可将 URL 替换成你自己的URL ，body 为你自己构建的请求体 ic.http_request 真正的去发送http 请求
  public func do_send_post(body : Text, uri : Text) : async Text {

    let url = "" #uri;
    let host = "";
    Cycles.add<system>(230_850_258_000);
    let ic : HttpTypes.IC = actor ("aaaaa-aa");
    let http_response : HttpTypes.HttpResponsePayload = await ic.http_request(get_http_req(body, url, host));
    let response_body : Blob = Blob.fromArray(http_response.body);
    let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    //6. RETURN RESPONSE OF THE BODY
    // let result : Text = decoded_text # ". See more info of the request sent at: " # url # "/inspect";
    let result : Text = decoded_text;
    result;
  };
```

- 绑定NFT 接口

```shell
public shared func binding_vfans(user_id : Text, ic_account_id : Text) : async Text {
    try {
      Debug.print("接收请求user_id=" #user_id # ",ic_account_id" #ic_account_id);
      //构建body
      let body = build_binding_body(user_id, ic_account_id, "bind");
      Debug.print(debug_show ("请求内容" #body));
      //发送http 请求
      let https_resp = await do_send_post(body, "icAccount");
      Debug.print(debug_show ("返回结果" #https_resp));
      //处理返回结果
      let result = deal_https_resp(https_resp, "binding");
      if (result != "处理成功") {
        let unbind_body = build_binding_body(user_id, ic_account_id, "unbind");
        Debug.print(debug_show ("请求内容" #body));
        //发送http 请求
        let _resp = await do_send_post(unbind_body, "icAccount");
        return result;
      };
    } catch e {
      Debug.print(show_error(e));
      let err_msg : Text = show_error(e);
      let aaa : ErrorLog = {
        error_time = Time.now();
        error_msg = err_msg;
        error_type = "绑定出错";
      };
      error_list := List.push(aaa, error_list);
      let body = build_binding_body(user_id, ic_account_id, "unbind");
      Debug.print(debug_show ("请求内容" #body));
      //发送http 请求
      let https_resp = await do_send_post(body, "icAccount");
      Debug.print(debug_show ("返回结果" #https_resp));
      return "处理失败";
    };
    "处理成功";
  };
```

- 异常存储

```shell
 let err_msg : Text = show_error(e);
  let aaa : ErrorLog = {
    error_time = Time.now();
    error_msg = err_msg;
    error_type = "绑定出错";
  };
  error_list := List.push(aaa, error_list);
```

- ic stable memory sstorage

```shell
  # 持久化存储异常日志
  stable var error_list = List.nil<ErrorLog>();
  # 持久化存储cycles 账单
  stable var cycles_ledger = List.nil<CyclesBalance>();
  # 持久化存储同步索引
  stable var update_list = List.nil<Text>();
  # 持久化存储NFT集合
  stable var nfts = List.nil<Types.Nft>(
```





## 测试

暂无

## Roadmap

暂无

## 开源许可

此项目是根据麻省理工学院许可证授权的，请参阅license.md了解详细信息。有关如何对此项目做出贡献的详细信息，请参阅CONTRIBUTE.md。

## 致谢

- Hat tip to anyone who's code was used
- External contributors
- Etc.

## References

- [Internet Computer](https://internetcomputer.org)
- Etiam dolor ante
- Nullam iaculis risus vitae
