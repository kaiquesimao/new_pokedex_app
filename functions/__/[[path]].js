/**
 * Reverse-proxy Firebase Auth helpers onto this site's origin.
 *
 * Same-origin `/__/auth/*` lets Firebase Auth work under COOP/COEP
 * (multi-thread Flutter Wasm). See:
 * https://firebase.google.com/docs/auth/web/redirect-best-practices#proxy-requests
 * https://github.com/firebase/flutterfire/issues/12819
 *
 * Set Pages env FIREBASE_AUTH_ORIGIN to override (defaults to this project).
 */
const DEFAULT_FIREBASE_AUTH_ORIGIN =
  'https://pokedex-app-c5e90.firebaseapp.com';

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const origin = (
    context.env.FIREBASE_AUTH_ORIGIN || DEFAULT_FIREBASE_AUTH_ORIGIN
  ).replace(/\/$/, '');
  const target = `${origin}${url.pathname}${url.search}`;

  const upstream = new Request(target, context.request);
  const response = await fetch(upstream);

  // Same-origin to the browser after proxy — strip hop-by-hop / encoding
  // surprises that can break streaming of handler HTML/JS.
  const headers = new Headers(response.headers);
  headers.delete('content-encoding');
  headers.delete('transfer-encoding');
  headers.set('Cache-Control', 'no-store');

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
