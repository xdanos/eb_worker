-module(ebalancer_store).
-author("xtovarn").

-behaviour(gen_server).

%% API
-export([start_link/0, remove_balancer/3, store/4, add_balancer/3]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

add_balancer(ServerRef, BalancerName, Timeout) ->
	gen_server:call(ServerRef, {add_balancer, BalancerName}, Timeout).

remove_balancer(ServerRef, BalancerName, Timeout) ->
	gen_server:call(ServerRef, {remove_balancer, BalancerName}, Timeout).

store(ServerRef, BalancerName, RawData, Timeout) ->
	gen_server:call(ServerRef, {store, BalancerName, RawData}, Timeout).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
	{ok, #state{}}.

handle_call({add_balancer, BalancerName}, _From, State) ->
	ets:new(BalancerName, [ordered_set, named_table]),
	{reply, ok, State};
handle_call({remove_balancer, BalancerName}, _From, State) ->
	ets:delete(BalancerName),
	{reply, ok, State};
handle_call({store, BalancerName, RawData}, _From, State) ->
	ets:insert(BalancerName, RawData),
	{reply, ok, State}.

handle_cast(_Request, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
