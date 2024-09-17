import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Asset { 'class' : AssetClass, 'symbol' : string }
export type AssetClass = { 'Cryptocurrency' : null } |
  { 'FiatCurrency' : null };
export interface CanisterHttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface HttpHeader { 'value' : string, 'name' : string }
export interface HttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface IcpTransactionSecondLogs {
  'to' : string,
  'time' : bigint,
  'txId' : bigint,
  'amount' : bigint,
}
export type List = [] | [[Log, List]];
export type List_1 = [] | [[IcpTransactionSecondLogs, List_1]];
export interface Log {
  'content' : string,
  'time' : bigint,
  'log_type' : LogType,
  'log_id' : bigint,
}
export type LogSet = [] | [[Log, List]];
export type LogType = { 'query_icp_rate' : null } |
  { 'simple' : null } |
  { 'query_icp_usd_rate' : null };
export interface ProxyTransferArgs {
  'vftCount' : number,
  'sign' : string,
  'time' : bigint,
  'toPrincipal' : string,
  'transfer_money_type' : bigint,
  'fromPrincipal' : string,
}
export interface RateRecord {
  'rate' : number,
  'currency_type' : Asset,
  'update_time' : bigint,
  'yesterday_rate' : number,
}
export type Result = { 'ok' : bigint } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
  { 'err' : string };
export interface Tokens { 'e8s' : bigint }
export interface TransferArgs {
  'accountId' : Uint8Array | number[],
  'amount' : Tokens,
}
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export interface VfansInfoRead {
  'exchange_RMB_amount' : number,
  'exchange_ICP_amount' : bigint,
  'vft_destyoy_toal_amount' : number,
  'exchange_VFT_amount' : number,
  'inventory_icp_amount' : bigint,
  'exchang_total_count' : bigint,
  'hold_ICP_account_count' : bigint,
  'exchang_total_ICP_amount' : bigint,
  'vft_issue_toal_amount' : number,
}
export interface VftTransactionLog {
  'log_vft_count' : number,
  'log_time' : bigint,
  'log_type' : VftTransactionLogType,
  'log_id' : bigint,
  'log_amount' : number,
}
export type VftTransactionLogType = { 'withdrawal_icp' : null } |
  { 'withdrawal_rmb' : null } |
  { 'register' : null };
export interface tokens { 'e8s' : bigint }
export interface _SERVICE {
  'add_icp_transaction_second_log' : ActorMethod<
    [IcpTransactionSecondLogs],
    string
  >,
  'do_get_exchange_rate' : ActorMethod<[Asset, boolean], RateRecord>,
  'get_exchange_rate' : ActorMethod<[Asset, boolean], RateRecord>,
  'get_exchange_rate_rmb' : ActorMethod<[boolean], RateRecord>,
  'get_exchange_rate_usd' : ActorMethod<[boolean], RateRecord>,
  'get_icp_transaction_second_log' : ActorMethod<
    [string],
    Array<IcpTransactionSecondLogs>
  >,
  'get_icp_transaction_second_log2' : ActorMethod<[], Array<[string, List_1]>>,
  'get_log' : ActorMethod<[], LogSet>,
  'init_exchang_total_count' : ActorMethod<[bigint], bigint>,
  'init_inventory_icp_amount' : ActorMethod<[bigint, string], boolean>,
  'proxy_transfer' : ActorMethod<[ProxyTransferArgs], Result>,
  'queryICP' : ActorMethod<[string], tokens>,
  'queryVfanInfo' : ActorMethod<[], VfansInfoRead>,
  'query_balance' : ActorMethod<[], bigint>,
  'query_sin_str' : ActorMethod<[ProxyTransferArgs], string>,
  'show_vft_transaction_log' : ActorMethod<[], Array<VftTransactionLog>>,
  'transfer' : ActorMethod<[TransferArgs], Result_1>,
  'transfer_rmb' : ActorMethod<[ProxyTransferArgs], Result>,
  'transform' : ActorMethod<[TransformArgs], CanisterHttpResponsePayload>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
