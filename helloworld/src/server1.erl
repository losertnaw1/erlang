-module(server1).
-behaviour(gen_server).
-export([start/0,send_msg/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

send_msg(From,To,Msg) -> gen_server:call(From,{send,Msg,To}).

init([]) ->
    %%erlang:send_after(5000,self(),{wfmsg,"Init schedule"}), 
    {ok, []}.

handle_call({send,Msg,To}, From, State) ->
    io:format("Sv1 : Sending message from ~p to ~p ~n",[From,To]),
    erlang:send(self(),"From sv1: Sent!"),
    gen_server:call(From,{got,Msg}),
    {reply, sent, State};
    
handle_call({got,Msg},_From,_State) ->
    {reply, {sv1_got, Msg} };
    
handle_call(sent, _, _) ->
    {reply, second_handlecall}.

handle_cast(sent,State) ->
    io:format("Sent !"),
    {noreply, State};

handle_cast(_Msg, State) ->
    Return = {noreply, State},
    io:format("handle_cast: ~p~n", [Return]),
    Return.
	
handle_info(Info, State) ->
    Return = {noreply, State},
    io:format("handle_info from server1: ~p~n", [Info]),
    Return.

terminate(_Reason, _State) ->
    Return = ok,
    io:format("terminate: ~p~n", [Return]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    Return = {ok, State},
    io:format("code_change: ~p~n", [Return]),
    Return.