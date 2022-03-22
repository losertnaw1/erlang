
%% @doc @todo Add description to dump_subdata.

-module(dump_subdata).
-behaviour(gen_fsm).

-export([init/1, 
		 wf_init_session/2, 
		 wf_subdata/2, 
		 handle_event/3, 
		 handle_sync_event/4, 
		 handle_info/3, 
		 terminate/3, 
		 code_change/4]).


%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/2]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {
		filepath,
		count
  }).

-record(event, {						
	id		:: tuple(),							
	orig	:: pid(),							
	dest	:: {atom(),node()} | pid(),			
	header	:: any(),							
	body	:: any()							
}).

start_link(Args,Count) ->	
	gen_fsm:start_link(?MODULE, {Args,Count}, []).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:init-1">gen_fsm:init/1</a>
-spec init(Args :: term()) -> Result when
	Result :: {ok, StateName, StateData}
			| {ok, StateName, StateData, Timeout}
			| {ok, StateName, StateData, hibernate}
			| {stop, Reason}
			| ignore,
	StateName :: atom(),
	StateData :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
init({FilePath,Count}) ->
	io:format("Server started : FilePath ~p , Count : ~p ~n",[FilePath,Count]),
    {ok, wf_init_session, #state{filepath=FilePath,count=Count}}.

%% state_name/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:StateName-2">gen_fsm:StateName/2</a>
-spec wf_init_session(Event :: timeout | term(), StateData :: term()) -> Result when
	Result :: {next_state, NextStateName, NewStateData}
			| {next_state, NextStateName, NewStateData, Timeout}
			| {next_state, NextStateName, NewStateData, hibernate}
			| {stop, Reason, NewStateData},
	NextStateName :: atom(),
	NewStateData :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
% @todo implement actual state
wf_init_session(#event{id = init_session, orig = Dest}, StateData) ->
	io:format("wf_init_session ~p ~p ~n",[Dest,StateData]),
	gen_fsm:send_event(Dest, #event{id = init_ack, orig = self()}),
    {next_state, wf_subdata, StateData,80000};

wf_init_session(timeout, StateData) ->
	io:format("timeout"),
	{stop, fail, StateData};

wf_init_session(Event, StateData) ->
	io:format("received unknow event ~p ~n",[Event]),
	{next_state, wf_init_session, StateData, 80000}.

%% state_name/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:StateName-3">gen_fsm:StateName/3</a>
-spec wf_subdata(Event :: timeout | term(), StateData :: term()) -> Result when
	Result :: {next_state, NextStateName, NewStateData}
			| {next_state, NextStateName, NewStateData, Timeout}
			| {next_state, NextStateName, NewStateData, hibernate}
			| {stop, Reason, NewStateData},
	NextStateName :: atom(),
	NewStateData :: atom(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: normal | term().
%% ====================================================================
wf_subdata(#event{id = subscriber_data_dump, orig = Dest,body = Subdata}, #state{filepath = FilePath,count=Count} = StateData) ->
	try
	    io:format("Write into ~p, with Subdata: ~p ~n",[FilePath, Subdata]),
		case Subdata of
			[] -> 
				io:format("Receive NULL String"),
				file:write_file(FilePath, "",[append]),
				gen_fsm:send_event(Dest, #event{id = subscriber_data_dump_ack, orig = self()}),
				{next_state, wf_subdata, StateData,80000};
			_ ->
				file:write_file(FilePath, Subdata,[append]),
				gen_fsm:send_event(Dest, #event{id = subscriber_data_dump_ack, orig = self()}),
				{next_state, wf_subdata, StateData,80000}
		end
	catch _:_ -> 
		io:format("Error write sub data first time"),
		try
			io:format("Rewrite subdata ~p",[FilePath]),
			file:write_file(FilePath, Subdata,[append]),
			gen_fsm:send_event(Dest, #event{id = subscriber_data_dump_ack, orig = self()}),
			{next_state, wf_subdata, StateData,80000}
		catch _:_ ->
			io:format("Error write sub data second time"),
			gen_fsm:send_event(Dest, #event{id = subscriber_data_dump_abort, orig = self()}),
			{stop, fail, StateData}
		end
	end;

wf_subdata(#event{id = subscriber_data_dump_end, orig = _Dest}, #state{filepath = FilePath,count=Count} = StateData) ->
	file:write_file(FilePath, "",[append]),	%%to reserver case vlr return subscriber_data_dump_end but file not created before
	io:format("Finish write subdata ~p",[FilePath]),
    {stop, normal, StateData};

wf_subdata(timeout, StateData) ->
	io:format("timeout"),
	{stop, fail, StateData};
	
wf_subdata(Event, StateData) ->
	io:format("received unknow event ~p",[Event]),
	{next_state, wf_subdata, StateData, 80000}.

%% handle_event/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:handle_event-3">gen_fsm:handle_event/3</a>
-spec handle_event(Event :: term(), StateName :: atom(), StateData :: term()) -> Result when
	Result :: {next_state, NextStateName, NewStateData}
			| {next_state, NextStateName, NewStateData, Timeout}
			| {next_state, NextStateName, NewStateData, hibernate}
			| {stop, Reason, NewStateData},
	NextStateName :: atom(),
	NewStateData :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
handle_event(_Event, StateName, StateData) ->
    {next_state, StateName, StateData}.


%% handle_sync_event/4
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:handle_sync_event-4">gen_fsm:handle_sync_event/4</a>
-spec handle_sync_event(Event :: term(), From :: {pid(), Tag :: term()}, StateName :: atom(), StateData :: term()) -> Result when
	Result :: {reply, Reply, NextStateName, NewStateData}
			| {reply, Reply, NextStateName, NewStateData, Timeout}
			| {reply, Reply, NextStateName, NewStateData, hibernate}
			| {next_state, NextStateName, NewStateData}
			| {next_state, NextStateName, NewStateData, Timeout}
			| {next_state, NextStateName, NewStateData, hibernate}
			| {stop, Reason, Reply, NewStateData}
			| {stop, Reason, NewStateData},
	Reply :: term(),
	NextStateName :: atom(),
	NewStateData :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
handle_sync_event(_Event, _From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.


%% handle_info/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:handle_info-3">gen_fsm:handle_info/3</a>
-spec handle_info(Info :: term(), StateName :: atom(), StateData :: term()) -> Result when
	Result :: {next_state, NextStateName, NewStateData}
			| {next_state, NextStateName, NewStateData, Timeout}
			| {next_state, NextStateName, NewStateData, hibernate}
			| {stop, Reason, NewStateData},
	NextStateName :: atom(),
	NewStateData :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: normal | term().
%% ====================================================================
handle_info(_Info, StateName, StateData) ->
    {next_state, StateName, StateData}.


%% terminate/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:terminate-3">gen_fsm:terminate/3</a>
-spec terminate(Reason, StateName :: atom(), StateData :: term()) -> Result :: term() when
	Reason :: normal
			| shutdown
			| {shutdown, term()}
			| term().
%% ====================================================================
terminate(Reason, _, _StatData) ->
	io:format("terminate with reason ~p~n",[Reason]),
	Reason.

%% code_change/4
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:code_change-4">gen_fsm:code_change/4</a>
-spec code_change(OldVsn, StateName :: atom(), StateData :: term(), Extra :: term()) -> {ok, NextStateName :: atom(), NewStateData :: term()} when
	OldVsn :: Vsn | {down, Vsn},
	Vsn :: term().
%% ====================================================================
code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}.


%% ====================================================================
%% Internal functions
%% ====================================================================


