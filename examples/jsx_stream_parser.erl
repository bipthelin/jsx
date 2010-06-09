%% The MIT License

%% Copyright (c) 2010 Alisdair Sullivan <alisdairsullivan@yahoo.ca>

%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:

%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.

%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.


-module(jsx_stream_parser).
-author("alisdairsullivan@yahoo.ca").

-export([decoder/1, event/2]).

decoder(Opts) ->
    Decoder = jsx:parser({jsx_stream_parser, event, 0}, Opts),
        fun(Stream) -> try
            case Decoder(Stream) of
                {incomplete, F} -> {incomplete, F}
                ; {error, badjson} -> {error, badjson}
            end
            catch
                throw:{ok, Result} -> {ok, Result}
                ; throw:not_found -> {error, not_found}
            end
        end.
    
event(start_object, Level) ->
    Level + 1;
    
event(start_array, 0) ->
    throw(not_found);    
event(start_array, Level) ->
    Level + 1;
    
event(end_object, Level) ->
    Level - 1;
event(end_array, Level) ->
    Level - 1;
    
event({key, "_id"}, 1) ->
    capture;
    
event({string, String}, capture) ->
    throw({ok, String});

event(reset, _) ->
    0;
event(end_of_json, _) ->
    throw(not_found);    
    
event(_, Level) ->
    Level.