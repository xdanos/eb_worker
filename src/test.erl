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
-export([ets/2]).

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

ets_read_all_2({List, Continuation}, Res) ->
	ets_read_all_2(ets:match(Continuation), [List | Res]);
ets_read_all_2('$end_of_table', Res) ->
	Res.

ets(N, Limit) ->
	Tab = ets_prepare(N),
	{Time, Value} = timer:tc(fun()-> ets_read_all(Tab, Limit) end),
	{Value, Time}.