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
%% Tool functions
%%====================================================================

-spec read_file_tool(binary()) -> map().
read_file_tool(Filename) ->
    Path = filename:absname(Filename),
    case file:read_file(Path) of
        {ok, Bin} -> #{file_path => Path, content => Bin};
        {error, R} -> #{file_path => Path, content => lists:flatten(io_lib:format("error: ~p", [R]))}
    end.

-spec get_file_type(string(), string()) -> string().
get_file_type(Path, Name) ->
    FilePath = filename:join(Path, Name),
    case filelib:is_dir(FilePath) of
        true -> "dir";
        false -> "file"
    end.

-spec list_files_tool(binary()) -> map().
list_files_tool(Path) ->
    FullPath = filename:absname(Path),
    Files = case file:list_dir(FullPath) of
        {ok, Entries} ->
            [#{filename => Name, type => get_file_type(FullPath, Name)} || Name <- Entries];
        {error, _Reason} ->
            []
    end,
    #{path => FullPath, files => Files}.

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
            % Ask = string:trim(Line),
            % Answer = execute_llm_call([#{role => user, content => Ask}]),
            % bot_say(Answer),
            Result = list_files_tool("."),
            io:format("list_files: ~p~n", [Result]),
            Text = "aaa",
            bot_say(Text),
            run_coding_agent_loop()
    end.

-spec execute_llm_call([map()]) -> binary().
execute_llm_call(Conversation) ->
    {ok, #{content := Text}} = llm:chat(big, Conversation),
    Text.

-spec bot_say(binary()) -> ok.
bot_say(Text) ->
    io:format("~sBot~s: ~ts~n", [?ASSISTANT_COLOR, ?RESET_COLOR, Text]).

