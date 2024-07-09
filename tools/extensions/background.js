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

// vim: set ts=2 sw=2 et:
