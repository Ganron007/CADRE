// MAIN-world hook — posts fetch/XHR metadata to content script (extension isolated world).
(function () {
  const post = (payload) => {
    window.dispatchEvent(new CustomEvent("dfir-nexus-capture", { detail: payload }));
  };
  const origFetch = window.fetch;
  window.fetch = async function (...args) {
    const res = await origFetch.apply(this, args);
    try {
      post({
        source: "fetch",
        url: String(args[0]),
        status: res.status,
        timestamp: new Date().toISOString(),
      });
    } catch (_) {}
    return res;
  };
})();
