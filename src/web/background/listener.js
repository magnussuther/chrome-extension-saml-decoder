function startListener() {
    chrome.webRequest.onBeforeRequest.addListener(
        function(details) {
            navigationListenerCallback(details);
        },
        {urls: ["<all_urls>"]},
        ["requestBody"]
    );
}