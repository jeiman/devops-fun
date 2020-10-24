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
backend default {
  .host = "localhost";
  .port = "8080";
  .connect_timeout = 500s;
  .first_byte_timeout = 500s;
}

#acl purger {
#  "127.0.0.1";
#  "52.221.14.88";
#}

sub vcl_recv {
  # Happens before we check if we have this in cache already.
  #
  # Typically you clean up the request here, removing cookies you don't need,
  # rewriting the request, etc.

  unset req.http.x-cache;

  # Redirect HTTP requests to HTTPS for our SSL website:
  if (client.ip != "127.0.0.1" && req.http.host ~ "www.domain.com") {
    set req.http.x-redir = "https://www.domain.com" + req.url;
    return(synth(850, ""));
  }

  if (req.url ~ "\.(jpg|jpeg|gif|png|tiff|tif|svg|swf|ico|css|vsd|doc|ppt|pps|xls|pdf|mp3|mp4|m4a|ogg|mov|avi|wmv|sxw|zip|gz|bz2|tgz|tar|rar|odc|odb|odf|odg|odi|odp|ods|odt|sxc|sxd|sxi|sxw|dmg|torrent|deb|msi|iso|rpm)$") {
    # cookies are irrelevant here
    unset req.http.Cookie;
    # unset req.http.Authorization;
  }

if (req.url ~ "^/listing.csv") {
      return (pass);
  }

  # Allow cache-purging requests only from the IP addresses in the above acl purger section (Step 4).
  # If a purge request comes from a different IP address, an error message will be produced:
  # if (req.method == "PURGE") {
  #   if (!client.ip ~ purger) {
  #     return(synth(405, "This IP is not allowed to send PURGE requests."));
  #   }
  #   return (purge);
  # }

  # Change the X-Forwarded-For header:
  if (req.restarts == 0) {
    if (req.http.X-Forwarded-For) {
      set req.http.X-Forwarded-For = client.ip;
    }
  }

  # Exclude those with basic authentication from caching
  if (req.http.Authorization) {
    return (pass);
  }

  # Invalidate cache if there are any POST and PUT requests
  if (req.method == "POST" || req.method == "PUT") {
    ban("req.url == " + req.url);
    return(pass);
  }

  # If request is not GET or HEAD, pass it through to backend and not cache it
  #if (req.method != "GET" && req.method != "HEAD") {
  #  return (pass);
  #}



  # Exclude RSS feeds from caching
  if (req.url ~ "/feed") {
    return (pass);
  }

  # Tell Varnish not to cache the WordPress admin and login pages
  if (req.url ~ "wp-admin|wp-login") {
    return (pass);
  }

  # WordPress sets many cookies that are safe to ignore. To remove them, snippet is below
  set req.http.cookie = regsuball(req.http.cookie, "wp-settings-\d+=[^;]+(; )?", "");
  set req.http.cookie = regsuball(req.http.cookie, "wp-settings-time-\d+=[^;]+(; )?", "");
  if (req.http.cookie == "") {
    unset req.http.cookie;
  }

  return (hash);
}

sub vcl_hit {
	set req.http.x-cache = "hit";
}

sub vcl_miss {
	set req.http.x-cache = "miss";
}

sub vcl_pass {
	set req.http.x-cache = "pass";
}

sub vcl_pipe {
	set req.http.x-cache = "pipe uncacheable";
}

sub vcl_hash {
  hash_data(req.url);
  if (req.http.host) {
      hash_data(req.http.host);
  } else {
      hash_data(server.ip);
  }
  return (lookup);
}

# Redirect HTTP to HTTPS using the sub vcl_synth directive with the following settings:
sub vcl_synth {
  set resp.http.x-cache = "synth synth";

  #if (resp.status == 405) {
  #  set resp.status = 401;
  #  return (deliver);
  #}

  if (resp.status == 850) {
    set resp.http.Location = req.http.x-redir;
    set resp.status = 301;
    return (deliver);
  }
}

# Cache-purging for a particular page must occur each time we make edits to that page. To implement this, we use the sub vcl_purge directive:
#sub vcl_purge {
#  set req.method = "GET";
#  set req.http.X-Purger = "Purged";
#  return (restart);
#}

sub vcl_backend_response {
  # Happens after we have read the response headers from the backend.
  #
  # Here you clean the response headers, removing silly Set-Cookie headers
  # and other mistakes your backend does.

  set beresp.ttl = 4h;
  set beresp.grace = 6h;

  if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504)
    {
        # This check is important. If is_bgfetch is true, it means that we've found and returned the cached object to the client,
        # and triggered an asynchoronus background update. In that case, if it was a 5xx, we have to abandon, otherwise the previously cached object
        # would be erased from the cache (even if we set uncacheable to true).
        if (bereq.is_bgfetch)
        {
            return (abandon);
        }

        # We should never cache a 5xx response.
        set beresp.uncacheable = true;
    }

  if (bereq.url !~ "wp-admin|wp-login|product|cart|checkout|my-account|/?remove_item=") {
    unset beresp.http.set-cookie;
  }
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

    # We want to unset the X-Varnish header as we don't want users doing ninja tricks
    unset resp.http.X-Varnish;

    # Add cache hit data
  if (obj.hits > 0) {
    # If hit add hit count
    # set resp.http.X-Cache = "HIT";
    set resp.http.x-cache-hits = obj.hits;
  } else {
    set resp.http.x-cache-hits = obj.hits + " No Hits";
    # set resp.http.X-Cache = "MISS";
  }

  if (obj.uncacheable) {
		set req.http.x-cache = req.http.x-cache + " uncacheable" ;
	} else {
		set req.http.x-cache = req.http.x-cache + " cached" ;
	}
	# uncomment the following line to show the information in the response
	set resp.http.x-cache = req.http.x-cache;

  if (req.http.X-Purger) {
    set resp.http.X-Purger = req.http.X-Purger;
  }
}