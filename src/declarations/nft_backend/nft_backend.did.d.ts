import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

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
export interface ICRC7NFT {
  'binding_vfans' : ActorMethod<[string, string], string>,
  'clean' : ActorMethod<[], undefined>,
  'deal_https_resp_test' : ActorMethod<[string, string], string>,
  'do_send_post' : ActorMethod<[string, string], string>,
  'getErrorLog' : ActorMethod<[], string>,
  'getUpdate' : ActorMethod<[bigint], string>,
  'get_version' : ActorMethod<[], string>,
  'make_test' : ActorMethod<[], undefined>,
  'nft_count' : ActorMethod<[], bigint>,
  'queryNfts' : ActorMethod<[string], string>,
  'queryNfts2' : ActorMethod<[bigint], string>,
  'query_balance' : ActorMethod<[], bigint>,
  'query_cycles_ledger' : ActorMethod<[], string>,
  'query_one_time' : ActorMethod<[], string>,
  'test_post' : ActorMethod<[string, string], string>,
  'test_query_one_time' : ActorMethod<[], string>,
  'transform' : ActorMethod<[TransformArgs], CanisterHttpResponsePayload>,
  'whoami' : ActorMethod<[], Principal>,
}
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export interface _SERVICE extends ICRC7NFT {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
