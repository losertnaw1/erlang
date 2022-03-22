
%% @doc @todo Add description to dump_subdata.

-module(dump_subdata_client).
-behaviour(gen_fsm).


-export([start_fsm/2,send_init/1,send_data/2,send_finish/1]).

-define(INIT_SESSION, init_session).
-define(SUBSCRIBER_DATA_DUMP, subscriber_data_dump).
-define(SUBSCRIBER_DATA_DUMP_END, subscriber_data_dump_end).
-define(SUBSCRIBER_DATA_DUMP_ABORT, subscriber_data_dump_abort).

-record(event, {						
	id		:: tuple(),							
	orig	:: pid(),							
	dest	:: {atom(),node()} | pid(),			
	header	:: any(),							
	body	:: any()							
}).

start_fsm(FilePath,Count)->
	dump_subdata:start_link(FilePath,Count).

init({FilePath,Count}) ->
	io:format("Client started : FilePath ~p, Count : ~p ~n",[FilePath,Count]),
    {ok, wf_init_ack, #state{filepath=FilePath,count=Count}}.

send_init(DestPid)->
	gen_fsm:send_event(DestPid, #event{id=?INIT_SESSION,
									orig=self(),
									dest=DestPid,
									body=self()}).

send_data(DestPid,SubData)->
	gen_fsm:send_event(DestPid, #event{id=?SUBSCRIBER_DATA_DUMP,
									  orig=self(),
									  dest=DestPid,
									  body=SubData}).

send_finish(DestPid)->
	gen_fsm:send_event(DestPid, #event{id=?SUBSCRIBER_DATA_DUMP_END,
									  orig=self(),
									  dest=DestPid}).

wf_init_ack(#event{id = init_ack, orig = Dest}, StateData) ->
	io:format("wf_init_ack ~p ~p ~n",[Dest,StateData]),
	send_init(Dest),
    {next_state, wf_subdata_ack, StateData,5000};

wf_init_ack(timeout, StateData) ->
	io:format("timeout"),
	{stop, fail, StateData};

wf_init_ack(Event, StateData) ->
	io:format("received unknow event ~p ~n",[Event]),
	{next_state, wf_init_ack, StateData, 5000}.

wf_subdate_ack(#event{id = subscriber_data_dump_ack, orig = Dest}, #state{filepath = FilePath,count=Count}) ->
	io:format("Got ack event from : ~p , Processing . State : ~p ~n", [Dest,StateData]),
	send_data(Dest,"omg "),
	{next_state, wf_subdata_ack, #state{filepath = FilePath,count=Count-1}};

wf_subdate_ack(#event{id = _, orig = Dest}, #state{filepath = _,count=0}) ->
	io:format("End of sending !"),
	send_finish(Dest),
	{next_state, wf_subdata_ack, #state{filepath = FilePath,count=Count-1}};

wf_subdata_ack(timeout, StateData) ->
	io:format("timeout"),
	{stop, normal, StateData};

wf_subdata_ack(Event, StateData) ->
	io:format("received unknow event ~p",[Event]),
	{next_state, wf_subdata_ack, StateData, 8000}.

handle_event(_Event, StateName, StateData) ->
    {next_state, StateName, StateData}.

handle_sync_event(_Event, _From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.

handle_info(_Info, StateName, StateData) ->
    {next_state, StateName, StateData}.

terminate(Reason, _, _StatData) ->
	io:format("terminate with reason ~p~n",[Reason]),
	Reason.

code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}.