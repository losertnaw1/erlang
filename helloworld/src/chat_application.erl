-module(chat_application).
-behaviour(gen_server).
-export([start/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) -> {ok, []}.

handle_call({send,Msg}, From, _State) ->
    send(From,Msg),
    receive
    	{From,hello} -> self() ! {self(),"Hello"},
    	io:format("Message from ~p to ~p : ~p~n",[From,self(),Msg]);
    	_ -> {error,nothing_sent}
    end.

send(Pid,Msg) -> self() ! {Pid,Msg}.

handle_cast({wfmsg,Msg}, State) ->
    io:format("Receive msg from handle_cast: ~p~n", [Msg]),
    {noreply, State};

handle_cast(_Msg, State) ->
    Return = {noreply, State},
    io:format("handle_cast: ~p~n", [Return]),
    Return.
	

handle_info({wfmsg,Msg}, State) ->
    erlang:send_after(1000,helloworld,{wfmsg,"Msg abcdasd"}),
    io:format("handle_cast Msg: ~p~n", [Msg]),
    {noreply, State};

handle_info(_Info, State) ->
    Return = {noreply, State},
    io:format("handle_info: ~p~n", [Return]),
    Return.

terminate(_Reason, _State) ->
    Return = ok,
    io:format("terminate: ~p~n", [Return]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    Return = {ok, State},
    io:format("code_change: ~p~n", [Return]),
    Return.