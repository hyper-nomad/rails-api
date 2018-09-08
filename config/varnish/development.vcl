#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and http://varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

import std;
import directors;    # load the directors

# Default backend definition. Set this to point to your content server.

backend sldev01 {
    .host = "127.0.0.1";
    .port = "8080";
    .probe = {
      .url = "/alive";
      .timeout = 2s;   
      .interval = 10s;
      .window = 10;
      .threshold = 3;
    }
}

#backend slstg02 {
#    .host = "10.132.22.18";
#    .port = "8080";
#    .probe = {
#      .url = "/alive";
#      .timeout = 2s; 
#      .interval = 10s; 
#      .window = 10;
#      .threshold = 3; 
#    }
#}


sub vcl_init {
    new sldev = directors.round_robin();
    slstg.add_backend(sldev01);
}


sub vcl_recv {
   #set req.backend = slstg;
   set req.backend_hint = slstg.backend();


   if (req.url ~ "\.(png|gif|jpg|swf|css|js)$") {
      set req.http.user-agent = "Mozilla";
      unset req.http.cookie;
      #return (lookup);
   }

   # reject illegal access
   if((req.url ~ ".*ali\.txt") && (req.http.Content-Type == "application/json") && ( req.method == "POST") ) {
      return (synth(422, "Unprocessable Entity"));
   }

   if (req.url == "/alive") {
      return (synth(200, "Number 5 is ALIVE!"));
   }

   # Only deal with "normal" types
   if (req.method != "GET" &&
      req.method != "HEAD" &&
      req.method != "PUT" &&
      req.method != "POST" &&
      req.method != "TRACE" &&
      req.method != "OPTIONS" &&
      req.method != "PATCH" &&
      req.method != "DELETE") {
     /* Non-RFC2616 or CONNECT which is weird. */
     return (pipe);
   } 


   # Happens before we check if we have this in cache already.
   # 
   # Typically you clean up the request here, removing cookies you don't need,
   # rewriting the request, etc.

   #if (req.http.host ~ "^api-stg\.redish\.jp") {
   #  #unset req.http.cookie;
   if (req.http.host ~ "api-stg\.redish\.jp") {
      set req.url = regsub(req.url, "^/api/", "/");
      set req.url = regsub(req.url, "^/", "/api/");
   }
   #if (req.http.host ~ "^stg2\.redish\.jp") {
   #   set req.backend_hint = slstg2.backend();
   #}

}

sub vcl_backend_response {
   # Happens after we have read the response headers from the backend.
   # 
   # Here you clean the response headers, removing silly Set-Cookie headers
   # and other mistakes your backend does.
   unset beresp.http.Server;
   unset beresp.http.X-Powered-By;
 
   # For static content strip all backend cookies
   if (bereq.url ~ "\.(css|js|png|gif|jp(e?)g)|swf|ico") {
       unset beresp.http.cookie;
   }
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    # 
    # You can do accounting or modifying the final object here.
}

sub vcl_pipe {
# Called upon entering pipe mode. In this mode, the request is passed on to the backend, and any further data from both the client and backend is passed on unaltered until either end closes the connection. Basically, Varnish will degrade into a simple TCP proxy, shuffling bytes back and forth. For a connection in pipe mode, no other VCL subroutine will ever get called after vcl_pipe.
  # Note that only the first request to the backend will have
  # X-Forwarded-For set.  If you use X-Forwarded-For and want to
  # have it set for all requests, make sure to have:
  # set bereq.http.connection = "close";
  # here.  It is not set by default as it might break some broken web
  # applications, like IIS with NTLM authentication.
  #set bereq.http.Connection = "Close";
  # Implementing websocket support (https://www.varnish-cache.org/docs/4.0/users-guide/vcl-example-websockets.html)
  return (pipe);
}

sub vcl_pass {
# Called upon entering pass mode. In this mode, the request is passed on to the backend, and the backend's response is passed on to the client, but is not entered into the cache. Subsequent requests submitted over the same client connection are handled normally.
  # return (pass);
}
