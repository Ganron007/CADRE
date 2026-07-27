/** MV3 service worker — batches captures to DFIR-Nexus push server. */
const DEFAULT_PUSH_URL = "http://127.0.0.1:4626/captures";

chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  if (msg.type === "capture") {
    chrome.storage.session.get(["captures"], (data) => {
      const captures = data.captures || [];
      captures.push(msg.payload);
      chrome.storage.session.set({ captures });
      sendResponse({ ok: true, count: captures.length });
    });
    return true;
  }
  if (msg.type === "flush") {
    chrome.storage.session.get(["captures", "pushUrl", "caseId", "pushToken"], async (data) => {
      const url = data.pushUrl || DEFAULT_PUSH_URL;
      const caseId = data.caseId;
      const token = data.pushToken;
      if (!caseId || !token) {
        sendResponse({ ok: false, error: "caseId and pushToken required" });
        return;
      }
      const body = { kind: "batch", case_id: caseId, captures: data.captures || [] };
      try {
        const resp = await fetch(url, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-Case-Id": caseId,
            "X-Push-Token": token,
          },
          body: JSON.stringify(body),
        });
        const json = await resp.json();
        chrome.storage.session.set({ captures: [] });
        sendResponse({ ok: resp.ok, result: json });
      } catch (e) {
        sendResponse({ ok: false, error: String(e) });
      }
    });
    return true;
  }
});
