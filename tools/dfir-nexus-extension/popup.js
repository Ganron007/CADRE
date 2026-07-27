const $ = (id) => document.getElementById(id);

chrome.storage.local.get(["caseId", "pushToken", "pushUrl"], (data) => {
  if (data.caseId) $("caseId").value = data.caseId;
  if (data.pushToken) $("pushToken").value = data.pushToken;
  if (data.pushUrl) $("pushUrl").value = data.pushUrl;
});

$("save").onclick = () => {
  chrome.storage.local.set({
    caseId: $("caseId").value.trim(),
    pushToken: $("pushToken").value.trim(),
    pushUrl: $("pushUrl").value.trim(),
  });
  chrome.storage.session.set({
    caseId: $("caseId").value.trim(),
    pushToken: $("pushToken").value.trim(),
    pushUrl: $("pushUrl").value.trim(),
  });
  $("status").textContent = "Saved.";
};

$("flush").onclick = () => {
  chrome.runtime.sendMessage({ type: "flush" }, (resp) => {
    $("status").textContent = JSON.stringify(resp, null, 2);
  });
};

window.addEventListener("dfir-nexus-capture", (ev) => {
  chrome.runtime.sendMessage({ type: "capture", payload: ev.detail });
});
