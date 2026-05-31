-module(test_runner_ffi).
-export([main/0]).

main() ->
    Modules = discover_test_modules(),
    filelib:ensure_dir("test-results/.gitkeep"),
    eunit:test(Modules, [
        verbose,
        {report, {eunit_surefire, [{dir, "test-results"}]}}
    ]).

discover_test_modules() ->
    {ok, Cwd} = file:get_cwd(),
    Paths = [P || P <- code:get_path(), is_list(P), lists:prefix(Cwd, P)],
    lists:flatten([
        case file:list_dir(Path) of
            {ok, Files} ->
                [list_to_atom(filename:basename(F, ".beam"))
                 || F <- Files, lists:suffix("_test.beam", F)];
            _ -> []
        end
        || Path <- Paths
    ]).
