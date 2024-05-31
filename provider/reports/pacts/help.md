# For assistance debugging failures

* The pact files have been stored locally in the following temp directory:
    /Users/ita/projects/personal/pact-ruby-example/provider/tmp/pacts

* The requests and responses are logged in the following log file:
    /Users/ita/projects/personal/pact-ruby-example/provider/log/pact.log

* Add BACKTRACE=true to the `rake pact:verify` command to see the full backtrace

* If the diff output is confusing, try using another diff formatter.
  The options are :unix, :embedded and :list

    Pact.configure do | config |
      config.diff_formatter = :embedded
    end

  See https://github.com/pact-foundation/pact-ruby/blob/master/documentation/configuration.md#diff_formatter for examples and more information.

* Check out https://github.com/pact-foundation/pact-ruby/wiki/Troubleshooting

* Ask a question on stackoverflow and tag it `pact-ruby`


The following changes have been made since the previous distinct version of this pact, and may be responsible for verification failure:

# Diff between versions 1.2.107 and 1.0 of the pact between Zoo App and Animal Service

The following changes were made about 22 hours ago (Thu 30 May 2024, 9:21pm +00:00)

     {
       "response": {
         "body": {
-          "name": "Betty"
+          "name": "Any name"
         }
       }
     },
     ... ,
-    {
-      "description": "a request for an alligator",
-      "providerState": "the service is down",
-      "request": {
-        "method": "get",
-        "path": "/alligator/3",
-        "query": ""
-      },
-      "response": {
-        "body": {
-          "message": "An error occurred!"
-        },
-        "headers": {
-          "Content-Type": "application/json"
-        },
-        "status": 500
-      }
-    }
   ]
 }

## Links

pact-version:
  title: Pact
  name: Pact between Zoo App (1.0) and Animal Service
  href: http://localhost:9292/pacts/provider/Animal%20Service/consumer/Zoo%20App/version/1.0
comparison-pact-version:
  title: Pact
  name: Pact between Zoo App (1.2.107) and Animal Service
  href: http://localhost:9292/pacts/provider/Animal%20Service/consumer/Zoo%20App/version/1.2.107
