export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  const List_1 = IDL.Rec();
  const IcpTransactionSecondLogs = IDL.Record({
    'to' : IDL.Text,
    'time' : IDL.Int64,
    'txId' : IDL.Int,
    'amount' : IDL.Nat,
  });
  const AssetClass = IDL.Variant({
    'Cryptocurrency' : IDL.Null,
    'FiatCurrency' : IDL.Null,
  });
  const Asset = IDL.Record({ 'class' : AssetClass, 'symbol' : IDL.Text });
  const RateRecord = IDL.Record({
    'rate' : IDL.Float64,
    'currency_type' : Asset,
    'update_time' : IDL.Int,
    'yesterday_rate' : IDL.Float64,
  });
  List_1.fill(IDL.Opt(IDL.Tuple(IcpTransactionSecondLogs, List_1)));
  const LogType = IDL.Variant({
    'query_icp_rate' : IDL.Null,
    'simple' : IDL.Null,
    'query_icp_usd_rate' : IDL.Null,
  });
  const Log = IDL.Record({
    'content' : IDL.Text,
    'time' : IDL.Int,
    'log_type' : LogType,
    'log_id' : IDL.Int,
  });
  List.fill(IDL.Opt(IDL.Tuple(Log, List)));
  const LogSet = IDL.Opt(IDL.Tuple(Log, List));
  const ProxyTransferArgs = IDL.Record({
    'vftCount' : IDL.Float64,
    'sign' : IDL.Text,
    'time' : IDL.Nat,
    'toPrincipal' : IDL.Text,
    'transfer_money_type' : IDL.Nat,
    'fromPrincipal' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const tokens = IDL.Record({ 'e8s' : IDL.Nat64 });
  const VfansInfoRead = IDL.Record({
    'exchange_RMB_amount' : IDL.Float64,
    'exchange_ICP_amount' : IDL.Nat,
    'vft_destyoy_toal_amount' : IDL.Float64,
    'exchange_VFT_amount' : IDL.Float64,
    'inventory_icp_amount' : IDL.Nat,
    'exchang_total_count' : IDL.Nat,
    'hold_ICP_account_count' : IDL.Nat,
    'exchang_total_ICP_amount' : IDL.Nat,
    'vft_issue_toal_amount' : IDL.Float64,
  });
  const VftTransactionLogType = IDL.Variant({
    'withdrawal_icp' : IDL.Null,
    'withdrawal_rmb' : IDL.Null,
    'register' : IDL.Null,
  });
  const VftTransactionLog = IDL.Record({
    'log_vft_count' : IDL.Float64,
    'log_time' : IDL.Int,
    'log_type' : VftTransactionLogType,
    'log_id' : IDL.Nat,
    'log_amount' : IDL.Float64,
  });
  const Tokens = IDL.Record({ 'e8s' : IDL.Nat64 });
  const TransferArgs = IDL.Record({
    'accountId' : IDL.Vec(IDL.Nat8),
    'amount' : Tokens,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat64, 'err' : IDL.Text });
  const HttpHeader = IDL.Record({ 'value' : IDL.Text, 'name' : IDL.Text });
  const HttpResponsePayload = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HttpHeader),
  });
  const TransformArgs = IDL.Record({
    'context' : IDL.Vec(IDL.Nat8),
    'response' : HttpResponsePayload,
  });
  const CanisterHttpResponsePayload = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HttpHeader),
  });
  return IDL.Service({
    'add_icp_transaction_second_log' : IDL.Func(
        [IcpTransactionSecondLogs],
        [IDL.Text],
        [],
      ),
    'do_get_exchange_rate' : IDL.Func([Asset, IDL.Bool], [RateRecord], []),
    'get_exchange_rate' : IDL.Func([Asset, IDL.Bool], [RateRecord], []),
    'get_exchange_rate_rmb' : IDL.Func([IDL.Bool], [RateRecord], []),
    'get_exchange_rate_usd' : IDL.Func([IDL.Bool], [RateRecord], []),
    'get_icp_transaction_second_log' : IDL.Func(
        [IDL.Text],
        [IDL.Vec(IcpTransactionSecondLogs)],
        ['query'],
      ),
    'get_icp_transaction_second_log2' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, List_1))],
        ['query'],
      ),
    'get_log' : IDL.Func([], [LogSet], []),
    'init_exchang_total_count' : IDL.Func([IDL.Nat], [IDL.Nat], []),
    'init_inventory_icp_amount' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'proxy_transfer' : IDL.Func([ProxyTransferArgs], [Result], []),
    'queryICP' : IDL.Func([IDL.Text], [tokens], []),
    'queryVfanInfo' : IDL.Func([], [VfansInfoRead], ['query']),
    'query_balance' : IDL.Func([], [IDL.Nat], ['query']),
    'query_sin_str' : IDL.Func([ProxyTransferArgs], [IDL.Text], []),
    'show_vft_transaction_log' : IDL.Func(
        [],
        [IDL.Vec(VftTransactionLog)],
        ['query'],
      ),
    'transfer' : IDL.Func([TransferArgs], [Result_1], []),
    'transfer_rmb' : IDL.Func([ProxyTransferArgs], [Result], []),
    'transform' : IDL.Func(
        [TransformArgs],
        [CanisterHttpResponsePayload],
        ['query'],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
