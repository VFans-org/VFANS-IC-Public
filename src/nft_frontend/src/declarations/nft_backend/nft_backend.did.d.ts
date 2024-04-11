import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

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
  'clean' : ActorMethod<[], undefined>,
  'deal_https_resp_test' : ActorMethod<[string, string], string>,
  'do_send_post' : ActorMethod<[string], string>,
  'getErrorLog' : ActorMethod<[], string>,
  'getSubNft2' : ActorMethod<[], bigint>,
  'getUpdate' : ActorMethod<[bigint], string>,
  'greet' : ActorMethod<[string], string>,
  'make_test' : ActorMethod<[], undefined>,
  'mintICRC7' : ActorMethod<[VFTParams], string>,
  'queryNfts' : ActorMethod<[string], string>,
  'query_one_time' : ActorMethod<[], string>,
  'switch_timer' : ActorMethod<[boolean], undefined>,
  'transform' : ActorMethod<[TransformArgs], CanisterHttpResponsePayload>,
  'whoami' : ActorMethod<[], Principal>,
}
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export interface VFTParams {
  'sbt_get_time' : string,
  'sbt_membership_category' : string,
  'vft_count' : string,
  'reputation_point' : string,
  'vft_info' : string,
  'user_id' : string,
  'sbt_card_number' : string,
  'sbt_card_image' : string,
  'ic_account_id' : string,
}
export interface _SERVICE extends ICRC7NFT {}
