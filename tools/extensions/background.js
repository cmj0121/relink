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
      .then((text) => injection(text, tab));
      break;
    case "relinkImage":
      const image = info.srcUrl;

      fetch(image)
      .then((response) => response.blob())
      .then((blob) => {
        const form = new FormData();

        form.append("type", "image");
        form.append("image", blob);

        fetch(BASE_API, {
          method: "POST",
          body: form,
        })
        .then((response) => response.json())
        .then((text) => injection(text, tab));
      });
      break;
  }
});

// using chrome.scripting.executeScript to inject the function
// into the active tab
function injection(text, tab) {
  chrome.scripting.executeScript({
    target: {tabId: tab.id},
    function: _injection,
    args: [text],
  });
}

// inject the css and js into the active tab
function _injection(text) {
  // copy the text to the clipboard
  navigator.clipboard.writeText(text);

  // inject the alert with the customized style
  let dom = document.createElement("div");
  dom.textContent = `Copy to clipboard: ${text}`;
  dom.style.cssText = `
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    width: 100vw;

    padding: 8px;

    border: 1px solid #d3d3d3;
    border-radius: 5px;
    font-family: monospace;
    font-size: 1em;
    background: #38a846 !important;
  `;
  document.body.appendChild(dom);

  // dismiss the alert after 3 seconds
  setTimeout(() => {
    // fade out the alert
    dom.style.transition = "opacity 1s";
    dom.style.opacity = 0;

    // remove the alert from the DOM after 1 second
    setTimeout(() => {
      document.body.removeChild(dom);
    }, 1000);
  }, 3000)
}

// vim: set ts=2 sw=2 et:
