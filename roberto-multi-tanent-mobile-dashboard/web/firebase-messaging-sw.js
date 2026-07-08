importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAnnvbb5ViHETDwkRsMpy-qydala6RxX60",
  authDomain: "tugatai-ai-platform.firebaseapp.com",
  projectId: "tugatai-ai-platform",
  storageBucket: "tugatai-ai-platform.firebasestorage.app",
  messagingSenderId: "423817374578",
  appId: "1:423817374578:web:ffba2650f063f9b3448beb"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);

  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
