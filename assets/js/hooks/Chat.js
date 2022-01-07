import {
    EmojiButton
} from '@joeattardi/emoji-button';
import BSN from "bootstrap.native";

export default {

    maybeScrollToBottom(el) {
        if (this.isUserNearBottom(el)) {
            this.scrollToBottom(el);
            this.removeScrollNotice();
        } else {
            this.addScrollNotice();
        }
    },
    scrollToBottom(el) {
        el.scrollTop = el.scrollHeight;
    },
    isUserNearBottom(el) {
        // 5 chat messages with padding
        const threshold = 404;
        const position = el.scrollTop + el.offsetHeight;
        const height = el.scrollHeight;
        const isNearBottom = position > height - threshold;
        // For when you need to debug chat scrolling
        // console.log(`scrollTop=${el.scrollTop} offsetHeight=${el.offsetHeight} threshold=${threshold} position=${position} height=${height} isNearBottom=${isNearBottom}`);
        return isNearBottom;
    },

    addScrollNotice() {
        document.getElementById("more-chat-messages").classList.remove("d-none");
    },
    removeScrollNotice() {
        document.getElementById("more-chat-messages").classList.add("d-none");
    },

    theme() {
        return this.el.dataset.theme;
    },
    emotes() {
        return JSON.parse(this.el.dataset.emotes);
    },

    updated() {
        this.scrollToBottom(document.getElementById('chat-messages'));
    },
    reconnected() {
        this.scrollToBottom(document.getElementById('chat-messages'));
    },
    mounted() {
        const parent = this;
        const glimeshEmojis = this.emotes();

        const picker = new EmojiButton({
            theme: this.theme(),
            position: 'top-start',
            autoHide: true,
            style: 'twemoji',
            emojiSize: '32px',
            custom: glimeshEmojis,
            categories: [
                'custom',
                'smileys',
                'people',
                'animals',
                'food',
                'activities',
                'travel',
                'objects',
                'flags',
                'symbols',
            ],
            initialCategory: 'custom'
        });

        const trigger = document.querySelector('.emoji-activator');
        if (trigger) {
            trigger.addEventListener('click', (e) => {
                e.preventDefault();
                picker.togglePicker(trigger)
            });
        }

        const chat = document.getElementById('chat_message-form_message');
        const chatMessages = document.getElementById('chat-messages');
        const chatForm = document.getElementById("chat-form");
        const toggleTimestamps = document.getElementById("toggle-timestamps");
        const toggleModIcons = document.getElementById("toggle-mod-icons");

        // Whenever the user changes their browser size, re-scroll them to the bottom
        window.addEventListener('resize', () => this.scrollToBottom(chatMessages));

        picker.on('emoji', selection => {
            let value = '';
            if (selection.custom) {
                value = selection.name;
            } else {
                value = selection.emoji;
            }

            const [start, end] = [chat.selectionStart, chat.selectionEnd];
            chat.value = chat.value.substring(0, start) + value + chat.value.substring(end, chat.value.length);
        });

        toggleTimestamps.addEventListener("click", (e) => {
            if (e["show_timestamps"]) {
                chatMessages.classList.add("show-timestamps");
            } else {
                chatMessages.classList.remove("show-timestamps");
            }
            this.maybeScrollToBottom(chatMessages);
            var username = toggleTimestamps.dataset.user;
            this.pushEvent("toggle_timestamps", username != "" ? {user: username} : {});
        });

        if(toggleModIcons != null) {
            toggleModIcons.addEventListener("click", (e) => {
                if (e["show_mod_icons"]) {
                    chatMessages.classList.add("show-mod-icons");
                } else {
                    chatMessages.classList.remove("show-mod-icons");
                }
                this.maybeScrollToBottom(chatMessages);
                var username = toggleModIcons.dataset.user;
                this.pushEvent("toggle_mod_icons", {user: username});
            });    
        }

        this.scrollToBottom(chatMessages);
        this.handleEvent("new_chat_message", (e) => {
            // Scroll if we need to
            this.maybeScrollToBottom(chatMessages);

            let thisMessage = document.getElementById('chat-message-' + e.message_id);
            // Apply a BS init to just the new chat message
            BSN.initCallback(thisMessage);
        });

        this.handleEvent("remove_timed_out_user_messages", (e) => {
            let offendingUserID = e["bad_user_id"];
            let offendingChatMessage = chatMessages.querySelectorAll(`[data-user-id=${CSS.escape(offendingUserID)}]`);
            // Have to hide them otherwise the tooltip gets stuck on removing the element
            offendingChatMessage.forEach(e => e.hidden = true);
        });

        this.handleEvent("remove_deleted_message", (e) => {
            document.getElementById("chat-message-" + e["message_id"]).hidden = true;
        });

        // Scrolling voo-doo
        this.handleEvent("scroll_to_bottom", (e) => {
            parent.scrollToBottom(chatMessages);
        });
        chatMessages.addEventListener("scroll", function () {
            if (chatMessages.scrollHeight - chatMessages.scrollTop === chatMessages.clientHeight) {
                parent.removeScrollNotice();
            }
        });

        let recentMessages = []; // Holds all user-sent messages
        let currentMessage = ""; // The current message the user is typing. Reset when sent.
        let currentIndex = -1; // The position the user is in of the array that holds the messages.

        chatForm.addEventListener("submit", function (e) {
            if (chat.value !== "" && chat.value.length <= 500) {
                recentMessages.unshift(chat.value); // Pushes the message to the array
                currentIndex = -1; // Resets the position
                // If the message sent is what the user was typing (NOT a previous message) reset currentMessage
                if (chat.value == currentMessage) {
                    currentMessage = ""
                }
            }
        });

        let chatHeightRows = 1;  // used for expanding the textarea as text is entered
        // Chat doesn't exist if they are not logged it, we check that before adding the listener
        if (chat) {
            chat.addEventListener("keyup", function(e) {
                if (e.code == "ArrowUp") {
                    e.stopPropagation();
                    // If no message is being typed and currentMessage was not sent
                    if (e.target.value == "" && currentMessage) {
                        e.target.value = currentMessage;
                        // Else we show the the previous message(s)
                    } else if (recentMessages.length !== 0 && recentMessages[currentIndex + 1]) {
                        e.target.value = recentMessages[currentIndex + 1];
                        currentIndex = currentIndex + 1
                    }
                    return false;
                } else if (e.code == "ArrowDown") {
                    e.stopPropagation();
                    // If there are more recent messages we show them
                    if (recentMessages.length !== 0 && recentMessages[currentIndex - 1]) {
                        e.target.value = recentMessages[currentIndex - 1];
                        currentIndex = currentIndex - 1;
                        // If we have no messages to show we set the value to current message
                    } else if (currentIndex - 1 == -1) {
                        e.target.value = currentMessage;
                        currentIndex = -1;
                    } else {
                        e.target.value = "" // Resets the box back to default
                    }
                    return false;
                } else if (e.code == "Enter" && !e.shiftKey) {
                    // capture enter key (as long as the user isn't holding shift) to use as the form submit now that we have a textarea instead of text input.
                    e.stopPropagation();
                    e.preventDefault();
                    chatHeightRows = 1;  // reset the chat height
                    chat.setAttribute("rows", chatHeightRows);
                    document.getElementById("chat_message-form").dispatchEvent(new Event("submit", {bubbles: true}))
                    return false;
                }
            });

            // Now that we have a textarea for chat input, the following handler is to prevent a trailing \n when users hit enter without holding shift.
            // This is important since we will display a large version of an emote when it is the only thing entered.
            chat.addEventListener('keydown', function(e) {
                if (e.code == "Enter" && !e.shiftKey) {
                    e.stopPropagation();
                    e.preventDefault();
                    return false;
                }
            });
        }

        // On input we set the currentMessage to what is being typed. Not triggered when user puts previous messages in the input box
        chatForm.addEventListener("input", function (e) {
            if (currentIndex == -1) {
                currentMessage = e.target.value;
            }

            // this will expand the textarea as users type up to 3 rows
            // it will not re-shrink unless the user clears the field entirely or hits enter to submit
            if ((e.target.scrollHeight > e.target.clientHeight) && (chatHeightRows < 3)) {
                chatHeightRows++;
                chat.setAttribute("rows", chatHeightRows);
            } else if ((e.target.scrollHeight < e.target.clientHeight) && (chatHeightRows > 1)) {
                chatHeightRows--;
                chat.setAttribute("rows", chatHeightRows);
            } else if (e.target.value == "") {
                chatHeightRows = 1;
                chat.setAttribute("rows", chatHeightRows);
            }
        });
    }
};
