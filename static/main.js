document.addEventListener("DOMContentLoaded", () => {
    const API_URL = 'https://rxe7s6bhv4.execute-api.us-east-2.amazonaws.com/prod';

    // DOM element selections
    const loginContainer = document.getElementById("login-container");
    const chatContainer = document.getElementById("chat-container");
    const usernameInput = document.getElementById("username-input");
    const loginButton = document.getElementById("login-button");
    const chat = document.getElementById("chat");
    const messageInput = document.getElementById("message-input");
    const sendButton = document.getElementById("send-button");
    let username = "";

    // Function to show errors
    function showError(message) {
        console.error('Error:', message);
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.textContent = message;
        chat.appendChild(errorDiv);
        setTimeout(() => errorDiv.remove(), 5000);
    }

    // Function to handle login
    loginButton.addEventListener("click", () => {
        console.log("Login button clicked");
        const enteredUsername = usernameInput.value.trim();
        if (enteredUsername) {
            username = enteredUsername;
            loginContainer.style.display = "none";
            chatContainer.style.display = "flex";
            console.log("Login successful for:", username);
            loadPreviousMessages().catch(error => {
                console.error("Error loading messages:", error);
                showError("Failed to load messages. Please check console for details.");
            });
        }
    });

    // Function to add a message to the chat
    function addMessage(message, sender, isRightAligned) {
        const messageElement = document.createElement("div");
        messageElement.classList.add("message", isRightAligned ? "message-right" : "message-left");
        
        const timestamp = new Date().toLocaleTimeString();
        messageElement.innerHTML = `
            <strong>${sender}</strong>
            <span class="message-text">${message}</span>
            <span class="timestamp">${timestamp}</span>
        `;
        
        chat.appendChild(messageElement);
        chat.scrollTop = chat.scrollHeight;
    }

    // Event listener for send button
    sendButton.addEventListener("click", async () => {
        const message = messageInput.value.trim();
        if (message) {
            try {
                console.log('Attempting to send message:', message);
                await storeMessageInDatabase(message, username);
                addMessage(message, username, true);
                messageInput.value = "";
            } catch (error) {
                console.error("Error sending message:", error);
                showError("Failed to send message. Please check console for details.");
            }
        }
    });

    // Allow pressing "Enter" to send the message
    messageInput.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
            sendButton.click();
        }
    });

    // Store message function using API
    async function storeMessageInDatabase(message, username) {
        try {
            console.log('Sending message to API:', { username, message });
            
            const response = await fetch(`${API_URL}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json', // Make sure this header is set
                },
                body: JSON.stringify({ username, message }) // JSON.stringify to ensure JSON format
            });
            
            if (!response.ok) {
                console.error(`Failed to store message. Status: ${response.status}`);
                throw new Error('Failed to store message');
            }
            
            const responseData = await response.json();
            console.log('Message stored successfully:', responseData);
            return responseData;
        } catch (error) {
            console.error('Error storing message:', error);
            throw error;
        }
    }

    // Fetch messages function using API
    async function fetchMessagesFromDatabase() {
        try {
            const response = await fetch(`${API_URL}`);
            if (!response.ok) {
                throw new Error('Failed to fetch messages');
            }
            
            const data = await response.json();
            
            // Ensure we are working with an array and sort by timestamp
            const messages = Array.isArray(data.body) ? data.body : [];
            messages.sort((a, b) => Number(a.Timestamp) - Number(b.Timestamp)); // Sort messages by Timestamp

            return messages;
        } catch (error) {
            console.error('Error fetching messages:', error);
            throw error;
        }
    }

    async function loadPreviousMessages() {
        try {
            console.log('Loading previous messages');
            const messages = await fetchMessagesFromDatabase();
            console.log('Retrieved messages:', messages);
            
            if (messages.length === 0) {
                console.log('No previous messages found');
                return;
            }

            messages.forEach(msg => {
                if (msg && msg.Username && msg.Message) {
                    const isCurrentUser = msg.Username === username;
                    console.log('Adding message:', {
                        username: msg.Username,
                        message: msg.Message,
                        isCurrentUser: isCurrentUser
                    });
                    addMessage(msg.Message, msg.Username, isCurrentUser);
                } else {
                    console.warn('Skipping invalid message:', msg);
                }
            });
            
            chat.scrollTop = chat.scrollHeight;
            console.log('Previous messages loaded successfully');
        } catch (error) {
            console.error('Error in loadPreviousMessages:', error);
            showError('Failed to load previous messages. Please check console for details.');
            throw error;
        }
    }
});
