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
-export([ets/2, list/2, new_test/0]).

ets_prepare(N) ->
	Tab = ets:new(undefined, [ordered_set]),
	[ets:insert(Tab, {I, create_binary(I)}) || I <- lists:seq(1, N)],
	Tab.

create_binary(I) ->
	B = integer_to_binary(I),
	A = <<"Ahoy1A6F51E0670: to=<araxxxx@gmail.com>, orig_to=<256254@mail.muni.cz>, relay=gmail-smtp-in.l.google.com[173.194.65.26]:25, delay=0.73, delays=0.19/0/0.1/0.45, dsn=2.0.0, status=sent (250 2.0.0 OK 1412051116 pv8si19198664wjc.98 - gsmtp)">>,
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
	list_read_all_2(split2(Continuation, Limit), Limit, [lists:reverse(Result) | TotalResult]).

list(N, Limit) ->
	L = list_prepare(N),
	{Time, Value} = timer:tc(fun() -> list_read_all(L, Limit) end),
	{Value, Time}.

new_test() ->
	{ok, Pid} = ets_proxy:start_link(name1),
	{ok, Pid2} = ets_proxy:start_link(name2),
	{ok, Pid3} = ets_proxy:start_link(name3),

	Array = array:from_list([Pid, Pid2, Pid3]),

	timer:tc(fun() -> [gen_server:call(array:get(I rem 3, Array), {insert, {I, create_binary(I)}}) || I <- lists:seq(1, 250000)] end).