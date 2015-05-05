-module(ets_proxy).
-author("xtovarn").

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {tab, requests = 0}).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
	{ok, #state{tab = ets:new(undefined, [ordered_set])}}.

handle_call({insert, Data}, _From, State = #state{requests = N}) ->
	ets:insert(State#state.tab, Data),
	{reply, ok, State#state{requests = N + 1}}.

handle_cast({insert, Data}, State = #state{requests = N}) ->
	ets:insert(State#state.tab, Data),
	{noreply, State#state{requests = N + 1}}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.