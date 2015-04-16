%%%-------------------------------------------------------------------
%%% @author xtovarn
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. IV 2015 10:41
%%%-------------------------------------------------------------------
-module(rh).
-author("xtovarn").

%% API
-export([rh1/2, test_perf/0]).

-define(MIN_INT, -576460752303423489).

rh1(Key, Nodes) ->
	{Result, _} = lists:foldl(
		fun(Node, {MaxNode, MaxValue}) ->
			Hash = erlang:phash2({Key, Node}),
			case Hash > MaxValue of
				true -> {Node, Hash};
				false -> {MaxNode, MaxValue}
			end
		end, {undefined, ?MIN_INT}, Nodes),
	Result.

test_perf() ->
	Nodes = [a,b,c,d,e,f,g,h,k,i,j,k,l],
	F =
		fun() ->
			[rh:rh1({key, key, 1, I}, Nodes) || I <- lists:seq(1,250000)]
		end,
	{Time, Value} = timer:tc(F),
	{Time / 1000000, Value}.
