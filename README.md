# Callstacking::Rails
[![Build Status](https://github.com/callstacking/callstacking-rails/actions/workflows/ci.yml/badge.svg)](https://github.com/callstacking/callstacking-rails/actions/workflows/ci.yml)

Call Stacking is a rolling, checkpoint debugger for Rails.  It records all of the critical method calls within your app, along with their important context (param/argument/return/local variable values).  

You no longer need to debug with `binding.pry` or `puts` statements, as the entire callstack for a given request is captured.

Demo video:
[![Watch the video](https://user-images.githubusercontent.com/4600/190929740-fc68e18f-9572-41be-9719-cc6a8077e97f.png)](https://www.youtube.com/watch?v=NGqnwcNWv_k)

Class method calls are labeled.  Return values for those calls are denoted with ↳

Arguments for a method will be listed along with their calling values.

For method returns ↳, the final values of the local variables will be listed when you hover over the entry.

<img width="1695" alt="CleanShot 2022-09-17 at 21 10 32@2x" src="https://user-images.githubusercontent.com/4600/190882603-a99e9358-9754-4cbf-ac68-a41d53afe747.png">

Subsequent calls within a method are visibly nested.

Call Stacking is a Rails engine that you mount within your Rails app.

Here's a sample debugging sessions recorded from a Jumpstart Rails based app I've been working on.  This is a request for the main page ( https://smartk.id/ ).

![image](https://user-images.githubusercontent.com/4600/190882432-58092e38-7ee2-4138-b13a-f45ff2b09227.png)

Call Stacking Rails records all of the critical method calls within your app, along with their important context (param/argument/return/local variable values).

All in a rolling panel, so that you can debug your call chains from any point in the stack.

You'll never have to debug with `puts` statements ever again.

Calls are visibly nested so that it's easy to see which calls are issued from which parent methods.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "callstacking-rails"
```

And then execute:
```bash
$ bundle
```

## CLI Setup
Register an account at callstacking.com:

> callstacking-rails register

Opens a browser window to register as a callstacking.com user.

> callstacking-rails setup

Interactively prompts you for your callstacking.com username/password.
Stores auth details in `~/.callstacking`.

You can have multiple environments.
The default is `development`.

The `development:` section in the `~/.callstacking` config contains your credentials.

By setting the RAILS_ENV environment you can maintain multiple settings.

Questions? Create an issue: https://github.com/callstacking/callstacking-rails/issues

## Enabling Tracing
                                        
Call Stacking provides a helper method `callstacking_setup` that you can use to enable tracing for a given request.

You control how you enable tracing.

Here's a sample setup to add tracing to your requests that both checks for the current user to be an admin 
and for a `debug` param to be set to `1`:

```
class ApplicationController < ActionController::Base
  include Callstacking::Rails::Helpers::InstrumentHelper

  around_action :callstacking_setup, if: -> { current_user&.admin? && params[:debug] == '1' }
```

For the above setup, you would you have to be authenticated as an admin and would append `?debug=1` 
to the URL you wish to trace.

e.g.

* http://localhost:3000/?debug=1
* http://example.com/?debug=1

The local Rails server log outputs the trace URL. 

## Production Environment

For production, you can provide the auth token via the `CALLSTACKING_API_TOKEN` environment variable.

Your API token values can be viewed at https://callstacking.com/api_tokens

The traces are recorded at https://callstacking.com/traces

## Local Development: Heads Up Debugger

For local HTML requests, once your page has rendered, you will see a `💥` icon on the right hand side.

Click the icon and observe the full callstack context.

For headless API requests, visit https://callstacking.com/traces to view your traces.

## Tests
``
rake app:test:all
``

## License
The gem is available as open source under the terms of the [GPLv3 License](https://www.gnu.org/licenses/gpl-3.0.en.html).
