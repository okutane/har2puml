import 'dart:collection';
import 'dart:convert';
import 'dart:io';

const client = 'browser';

void main() {
  var servers = new LinkedHashMap();

  stdin
    .transform(UTF8.decoder)
    .transform(JSON.decoder)
    .listen((har) {
      har['log']['entries'].forEach((e) {
        var url = e['request']['url'];
        var uri = Uri.parse(url);

        var prefix = servers.keys.firstWhere((key) => url.startsWith(key), orElse:() {
          var servlet = uri.path.substring(1, uri.path.indexOf('/', 1));
          var newRequest = uri.path.substring(uri.path.indexOf('/', 1));
          var prefix = url.substring(0, 1 + url.indexOf(newRequest));

          servers[prefix] = servlet;
 
          return prefix;
        });

        var server = servers[prefix];
        var request = url.substring(url.indexOf(prefix));
      
        stdout.writeln('$client -> $server : $request');
      });
    });
}

