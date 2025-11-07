(function() {
  if (typeof fragmentElement === 'undefined') return;

  // Initialize AI Chat
  function initChatWidget() {
    const toggleBtn = fragmentElement.querySelector('.chat-toggle-btn');
    const minimizeBtn = fragmentElement.querySelector('.chat-minimize-btn');
    const chatWindow = fragmentElement.querySelector('.chat-window');

    if (!toggleBtn || !chatWindow) return;

    // Toggle chat window
    function toggleChat() {
      const isOpen = chatWindow.classList.contains('chat-open');
      
      if (isOpen) {
        closeChat();
      } else {
        openChat();
      }
    }

    // Open chat window
    function openChat() {
      chatWindow.classList.add('chat-open');
      toggleBtn.classList.add('active');
      
      // Dispatch custom event
      const event = new CustomEvent('aiChatOpened', {
        bubbles: true,
        detail: { timestamp: new Date().toISOString() }
      });
      fragmentElement.dispatchEvent(event);
      
      // Store state in localStorage
      try {
        localStorage.setItem('swe-chat-state', 'open');
      } catch (e) {
        // Ignore localStorage errors
      }
    }

    // Close chat window
    function closeChat() {
      chatWindow.classList.remove('chat-open');
      toggleBtn.classList.remove('active');
      
      // Dispatch custom event
      const event = new CustomEvent('aiChatClosed', {
        bubbles: true,
        detail: { timestamp: new Date().toISOString() }
      });
      fragmentElement.dispatchEvent(event);
      
      // Store state in localStorage
      try {
        localStorage.setItem('swe-chat-state', 'closed');
      } catch (e) {
        // Ignore localStorage errors
      }
    }

    // Toggle button click handler
    toggleBtn.addEventListener('click', toggleChat);

    // Minimize button click handler
    if (minimizeBtn) {
      minimizeBtn.addEventListener('click', closeChat);
    }

    // Close chat when clicking outside (optional)
    document.addEventListener('click', function(e) {
      if (!fragmentElement.contains(e.target) && chatWindow.classList.contains('chat-open')) {
        // Optionally auto-close when clicking outside
        // Uncomment the line below to enable this behavior
        // closeChat();
      }
    });

    // Restore chat state from localStorage
    try {
      const savedState = localStorage.getItem('swe-chat-state');
      if (savedState === 'open') {
        openChat();
      }
    } catch (e) {
      // Ignore localStorage errors
    }

    // ESC key to close chat
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && chatWindow.classList.contains('chat-open')) {
        closeChat();
      }
    });

    // Public API for programmatic control
    window.SWEChatWidget = {
      open: openChat,
      close: closeChat,
      toggle: toggleChat,
      isOpen: function() {
        return chatWindow.classList.contains('chat-open');
      },
      showNotification: function() {
        toggleBtn.classList.add('has-notification');
      },
      hideNotification: function() {
        toggleBtn.classList.remove('has-notification');
      }
    };
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initChatWidget);
  } else {
    initChatWidget();
  }
})();