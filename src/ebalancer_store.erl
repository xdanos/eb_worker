-module(ebalancer_store).
-author("xtovarn").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {store :: tid(), next_unique_id :: integer(), msg_counter :: integer(), msg_threshold :: integer()}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
	{ok, #state{store = ets:new(undefined, [ordered_set]), next_unique_id = 1, msg_counter = 0, msg_threshold = 10}}.

handle_call({store, RawData}, _From, #state{store = Tab, next_unique_id = Id, msg_counter = N} = State) ->
	ets:insert(Tab, {Id, RawData}),
	{reply, ok, State#state{next_unique_id = N + 1, msg_counter = N + 1}}.

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
