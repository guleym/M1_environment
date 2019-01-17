#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Default backend definition. Set this to point to your content server.

# backend apache instance.
backend default {
    # IP was taken from nginx.yml, it is Nginx container IP address
    # nginx
    .host = "172.28.1.11";
    .port = "8000";

    # IP was taken from apache.yml, it is Apache container IP address
    # apache
    #.host = "172.28.1.10";
    #.port = "8080";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    if (req.http.x-forwarded-for) {
         set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
    } else {
         set req.http.X-Forwarded-For = client.ip;
    }

    # Switching Varnish into pipe mode, it will shuffle bytes back and forth without caching functionality.
    # Parameter 'pipe_timeout' was changed from the default value 60s to 450s because of the Elasticsearch reindex.
    # It takes too long and Varnish drops pipe connection. It is the run time parameter.
    if (req.http.host ~ "dev.example.com") {
        return (pipe);
    }
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
}
