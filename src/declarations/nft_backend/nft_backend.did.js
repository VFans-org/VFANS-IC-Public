export const idlFactory = ({ IDL }) => {
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
    'binding_vfans' : IDL.Func([IDL.Text, IDL.Text], [IDL.Text], []),
    'clean' : IDL.Func([], [], []),
    'deal_https_resp_test' : IDL.Func([IDL.Text, IDL.Text], [IDL.Text], []),
    'do_send_post' : IDL.Func([IDL.Text, IDL.Text], [IDL.Text], []),
    'getErrorLog' : IDL.Func([], [IDL.Text], ['query']),
    'getUpdate' : IDL.Func([IDL.Nat], [IDL.Text], ['query']),
    'get_version' : IDL.Func([], [IDL.Text], []),
    'make_test' : IDL.Func([], [], []),
    'nft_count' : IDL.Func([], [IDL.Nat], ['query']),
    'queryNfts' : IDL.Func([IDL.Text], [IDL.Text], ['query']),
    'queryNfts2' : IDL.Func([IDL.Nat], [IDL.Text], ['query']),
    'query_balance' : IDL.Func([], [IDL.Nat], ['query']),
    'query_cycles_ledger' : IDL.Func([], [IDL.Text], ['query']),
    'query_one_time' : IDL.Func([], [IDL.Text], []),
    'test_post' : IDL.Func([IDL.Text, IDL.Text], [IDL.Text], []),
    'test_query_one_time' : IDL.Func([], [IDL.Text], []),
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
