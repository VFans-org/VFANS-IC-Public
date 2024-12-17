# VFANS-IC

The VFANS Soulbound Token (SBT) is a non-transferable NFT (non-fungible token) that securely stores your VFAN asset information on the blockchain. Built using the ICRC-7 standard, this SBT represents your on-chain account and ensures the safety of your asset data.

Key Features:

1. Secure On-Chain Storage: Your VFAN asset information is securely stored on the blockchain, ensuring its integrity and availability.
2. Internet Identity Integration: Connect your VFAN account with your Internet Identity for seamless access and management.
3. Synchronized Data: Your SBT is kept updated with your VFAN account information through automatic synchronization using Internet Computer HTTP outcalls and scheduled tasks.
4. Built-in Billing: Monitor your canister's cycles balance and daily consumption in real-time to effectively manage your resources.
5. Internet Identity Flexibility: If you lose access to your Internet Identity, you can easily change it without losing your VFTs. Your VFAN account remains secure, and your SBT will be updated to reflect the new associated principal ID.


## Data Follow


- Data Flow of SBT Mint

![image](https://github.com/VFans-org/VFANS-IC-Public/assets/107297097/7473330a-a415-4386-bd40-4392a184d1ce)


  - Data Snyc Process

![image](https://github.com/VFans-org/VFANS-IC-Public/assets/107297097/1e4e366a-cb2a-40f6-96a6-1ee65a03d394)



## Depolyment

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
