const BASE_URL = "https://401.tw";
const BASE_API = `${BASE_URL}/api/squash`;

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: "relinkLink",
    title: "ReLink the target Link",
    contexts: ["link"]
  });

  chrome.contextMenus.create({
    id: "relinkImage",
    title: "ReLink the target Image",
    contexts: ["image"]
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  switch (info.menuItemId) {
    case "relinkLink":
      let payload = {
        "type": "link",
        "link": info.linkUrl,
      };

      fetch(BASE_API, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      })
      .then((response) => response.json())
      .then((text) => copyToClipboard(text, tab));
  }
});

function _copyToClipboard(text) {
  navigator.clipboard.writeText(text)
}

function copyToClipboard(text, tab) {
  chrome.scripting.executeScript({
    target: {tabId: tab.id},
    function: _copyToClipboard,
    args: [text],
  });
}

// vim: set ts=2 sw=2 et:
