import 'dart:collection';
import 'dart:convert';
import 'dart:io';

const maxLeft = 20;
const maxRight = 10;
const maxLength = maxLeft + maxRight;

const client = 'browser';

void main() {
  var servers = new LinkedHashMap();

  stdin.transform(UTF8.decoder).transform(JSON.decoder).listen((har) {
    har['log']['entries'].forEach((e) {
      var url = e['request']['url'];
      var uri = Uri.parse(url);

      var prefix =
          servers.keys.firstWhere((key) => url.startsWith(key), orElse: () {
        var pathIndex = uri.path.indexOf('/', 1);
        var servlet = pathIndex == -1
            ? uri.path.substring(1)
            : uri.path.substring(1, pathIndex);
        var newRequest = pathIndex == -1 ? '/' : uri.path.substring(pathIndex);

        var prefix = (newRequest == '/')
            ? url
            : url.substring(0, 1 + url.indexOf(newRequest));

        servers[prefix] = servlet;

        return prefix;
      });

      var server = servers[prefix];
      var request = uri.hasQuery
          ? url.substring(prefix.length, url.indexOf('?'))
          : url.substring(prefix.length);

      var requestMsg = request.length > maxLength ? request.substring(0, maxLeft) + '..' + request.substring(request.length - maxRight) : request;

      stdout.writeln('$client -> "$server" : $requestMsg');

      var response = e['response'];

      var serverMsgBuffer = new StringBuffer();

      serverMsgBuffer.write(response['status']);
      serverMsgBuffer.write(' ');
      serverMsgBuffer.write(response['statusText']);
      var serverMsg = serverMsgBuffer.toString();

      stdout.writeln('$client <- "$server" : $serverMsg');
    });
  });
}
