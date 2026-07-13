import 'dart:developer' as developer;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

bool _installed = false;

@JS('eval')
external void _eval(JSString code);

/// Forwards browser `console.error`/`console.warn` and uncaught JS errors to
/// Dart `developer.log` so they appear in the Flutter debug console.
void installBrowserConsoleBridge() {
  if (_installed) return;
  _installed = true;

  globalContext.setProperty(
    '_pokedexOnBrowserLog'.toJS,
    ((JSString level, JSString message) {
      final name = level.toDart;
      developer.log(
        message.toDart,
        name: 'browser.console',
        level: name == 'error' ? 1000 : 900,
      );
    }).toJS,
  );

  _eval(
    '''
(function () {
  if (window.__pokedexConsolePatched) return;
  window.__pokedexConsolePatched = true;

  function forward(level) {
    var original = console[level];
    console[level] = function () {
      original.apply(console, arguments);
      if (!window._pokedexOnBrowserLog) return;
      var message = Array.prototype.slice.call(arguments).map(String).join(' ');
      window._pokedexOnBrowserLog(level, message);
    };
  }

  ['error', 'warn'].forEach(forward);

  window.addEventListener('error', function (event) {
    if (!window._pokedexOnBrowserLog) return;
    window._pokedexOnBrowserLog(
      'error',
      event.message + ' @ ' + event.filename + ':' + event.lineno,
    );
  });

  window.addEventListener('unhandledrejection', function (event) {
    if (!window._pokedexOnBrowserLog) return;
    window._pokedexOnBrowserLog(
      'error',
      'Unhandled rejection: ' + event.reason,
    );
  });
})();
'''
        .toJS,
  );
}
