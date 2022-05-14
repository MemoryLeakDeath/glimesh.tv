let wrappedHooks = [];

export default {
    mounted() {
        let shadowRootElementId = this.el.dataset.shadowRootElement;
        let shadowRootElement = document.getElementById(shadowRootElementId);
        let shadowHooks = shadowRootElement.shadowRoot.querySelectorAll('[phx-hook]');
        shadowHooks.forEach((hook) => {
            let hookName = hook.attributes.getNamedItem('phx-hook').value;
            let wrappedHook = Object.create(this.liveSocket.hooks[hookName]);    
            wrappedHook.el = hook;
            wrappedHook.__view = this.__view;
            wrappedHook.liveSocket = this.liveSocket;
            wrappedHook.__callbacks = this.__callbacks;
            wrappedHook.__listeners = this.__listeners;
            wrappedHook.__isDisconnected = this.__isDisconnected;
            wrappedHook.handleEvent = this.handleEvent;
            wrappedHook.pushEvent = this.pushEvent;
            wrappedHook.pushEventTo = this.pushEventTo;
            wrappedHook.upload = this.upload;
            wrappedHook.uploadTo = this.uploadTo;
            wrappedHooks.push(wrappedHook);
        });
        wrappedHooks.forEach((hook) => {
            hook.mounted();
        });
        this.handleEvent('populateShadowRoot', ({html}) => {
            shadowRootElement.shadowRoot.innerHTML = html;
        });
    },
    beforeUpdate() {
        wrappedHooks.forEach((hook) => {
            hook.beforeUpdate();
        });
    },
    updated() {
        wrappedHooks.forEach((hook) => {
            hook.updated();
        });
    },
    destroyed() {
        wrappedHooks.forEach((hook) => {
            hook.destroyed();
        });
        wrappedHooks = [];
    },
    disconnected() {
        wrappedHooks.forEach((hook) => {
            hook.disconnected();
        });
    },
    reconnected() {
        wrappedHooks.forEach((hook) => {
            hook.reconnected();
        });
    }
};