-module(tinyagent).

%% API exports
-export([main/1]).


-define(YOUR_COLOR, "\e[94m").
-define(ASSISTANT_COLOR, "\e[93m").
-define(RESET_COLOR, "\e[0m").

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main(Args) ->
    run_coding_agent_loop(),
    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================

run_coding_agent_loop() ->
    io:format("~sYou~s", [?YOUR_COLOR, ?RESET_COLOR]),
    case io:get_line(": ") of
        eof ->
            io:format("~n~sBot~s: Bye!~n", [?ASSISTANT_COLOR, ?RESET_COLOR]),
            ok;
        {error, Reason} ->
            io:format("Error: ~p~n", [Reason]),
            run_coding_agent_loop();
        Line ->
            Text = string:trim(Line),
            io:format("Say: ~s~n", [Text]),
            run_coding_agent_loop()
    end.

