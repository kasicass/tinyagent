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
main(_Args) ->
    run_coding_agent_loop(),
    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================

run_coding_agent_loop() ->
    io:format("~sYou~s", [?YOUR_COLOR, ?RESET_COLOR]),
    case io:get_line(": ") of
        eof ->
            io:format("~n"),
            bot_say("Bye!");
        {error, Reason} ->
            io:format("Error: ~p~n", [Reason]),
            run_coding_agent_loop();
        Line ->
            Ask = string:trim(Line),
            Answer = execute_llm_call([#{role => user, content => Ask}]),
            bot_say(Answer),
            #{ content := Text } = read_file_tool("src/tinyagent.app.src"),
            bot_say(Text),
            run_coding_agent_loop()
    end.

-spec read_file_tool(binary()) -> map().
read_file_tool(Filename) ->
    Path = filename:absname(Filename),
    case file:read_file(Path) of
        {ok, Bin} -> #{file_path => Path, content => Bin};
        {error, R} -> #{file_path => Path, content => lists:flatten(io_lib:format("error: ~p", [R]))}
    end.

-spec execute_llm_call([map()]) -> binary().
execute_llm_call(Conversation) ->
    {ok, #{content := Text}} = llm:chat(big, Conversation),
    Text.

-spec bot_say(binary()) -> ok.
bot_say(Text) ->
    io:format("~sBot~s: ~ts~n", [?ASSISTANT_COLOR, ?RESET_COLOR, Text]).

