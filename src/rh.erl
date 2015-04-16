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
-export([rh1/2, test_perf/0, rh2/2]).

rh1(Key, Nodes) ->
	Fun = fun(Node, {MaxNode, MaxValue}) ->
		Hash = erlang:phash2({Key, Node}),
		case Hash > MaxValue of
			true -> {Node, Hash};
			false -> {MaxNode, MaxValue}
		end
	end,
	{Result, _} = lists:foldl(Fun, {undefined, -1}, Nodes),
	Result.

rh2(Key, Nodes) ->
	Fun = fun(Node, {MaxNode, MaxValue}) ->
		Hash = erlang:phash2({Key, Node}),
		case Hash > MaxValue of
			true -> {Node, Hash};
			false -> {MaxNode, MaxValue}
		end
	end,
	{Result, _} = ec_plists:fold(Fun, {undefined, -1}, Nodes, 8),
	Result.


test_perf() ->
	Nodes = [a, b, c, d, e, f, g, h, k, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z],
	F =
		fun() ->
			[rh:rh1({key, key, 1, I}, Nodes) || I <- lists:seq(1, 200000)]
		end,
	{Time, Value} = timer:tc(F),
	{Time / 1000000, Value}.
