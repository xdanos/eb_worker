%%%-------------------------------------------------------------------
%%% @author xtovarn
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. IV 2015 10:18
%%%-------------------------------------------------------------------
-module(test).
-author("xtovarn").

%% API
-export([ets/2, list/2]).

ets_prepare(N) ->
	Tab = ets:new(undefined, [ordered_set]),
	[ets:insert(Tab, {I, create_binary(I)}) || I <- lists:seq(1, N)],
	Tab.

create_binary(I) ->
	B = integer_to_binary(I),
	A = <<"Ahoy">>,
	<<A/binary, B/binary>>.

ets_read_all(Tab, Limit) ->
	ets_read_all_2(ets:match(Tab, '$1', Limit), []).

ets_read_all_2({Result, Continuation}, TotalResult) ->
	ets_read_all_2(ets:match(Continuation), [Result | TotalResult]);
ets_read_all_2('$end_of_table', TotalResult) ->
	TotalResult.

ets(N, Limit) ->
	Tab = ets_prepare(N),
	{Time, Value} = timer:tc(fun() -> ets_read_all(Tab, Limit) end),
	{Value, Time}.

list_prepare(N) ->
	lists:reverse([create_binary(I) || I <- lists:seq(1, N)]).

list_read_all(List, Limit) ->
	list_read_all_2(split2(List, Limit), Limit, []).

split2(List, Limit) when length(List) > Limit ->
	lists:split(length(List) - Limit, List);
split2(List, _Limit) ->
	{[], List}.

list_read_all_2({[], Result}, _Limit, Res) ->
	[lists:reverse(Result) | Res];
list_read_all_2({Continuation, Result}, Limit, TotalResult) ->
	list_read_all_2(split2(Continuation, Limit), Limit, [lists:(Result) | TotalResult]).

list(N, Limit) ->
	L = list_prepare(N),
	{Time, Value} = timer:tc(fun() -> list_read_all(L, Limit) end),
	{Value, Time}.