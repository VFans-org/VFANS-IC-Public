export const idlFactory = ({ IDL }) => {
  const VFTParams = IDL.Record({
    'sbt_get_time' : IDL.Text,
    'sbt_membership_category' : IDL.Text,
    'vft_count' : IDL.Text,
    'reputation_point' : IDL.Text,
    'vft_info' : IDL.Text,
    'user_id' : IDL.Text,
    'sbt_card_number' : IDL.Text,
    'sbt_card_image' : IDL.Text,
    'ic_account_id' : IDL.Text,
  });
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
  const ICRC7NFT = IDL.Service({
    'clean' : IDL.Func([], [], []),
    'deal_https_resp_test' : IDL.Func([IDL.Text, IDL.Text], [IDL.Text], []),
    'do_send_post' : IDL.Func([IDL.Text], [IDL.Text], []),
    'getErrorLog' : IDL.Func([], [IDL.Text], ['query']),
    'getSubNft2' : IDL.Func([], [IDL.Nat], ['query']),
    'getUpdate' : IDL.Func([IDL.Nat], [IDL.Text], ['query']),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], ['query']),
    'make_test' : IDL.Func([], [], []),
    'mintICRC7' : IDL.Func([VFTParams], [IDL.Text], []),
    'queryNfts' : IDL.Func([IDL.Text], [IDL.Text], ['query']),
    'query_one_time' : IDL.Func([], [IDL.Text], []),
    'switch_timer' : IDL.Func([IDL.Bool], [], ['query']),
    'transform' : IDL.Func(
        [TransformArgs],
        [CanisterHttpResponsePayload],
        ['query'],
      ),
    'whoami' : IDL.Func([], [IDL.Principal], []),
  });
  return ICRC7NFT;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
