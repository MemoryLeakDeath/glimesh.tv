
export default {
    mounted() {
        let thisElement = this.el;
        let shadowRootElement = document.getElementById('costream-panel');
        let toDataUsername = thisElement.dataset.username;
        thisElement.addEventListener("click", (event) => {
            // unselect if this was selected
            if(thisElement.classList.contains('costream-swap-from-button')) {
                thisElement.classList.remove('costream-swap-from-button');
                shadowRootElement.shadowRoot.querySelector('.costream-swap-from').classList.remove('costream-swap-from');
                return;
            }

            let fromElement = shadowRootElement.shadowRoot.querySelector('.costream-swap-from');
            let fromElementButton = shadowRootElement.shadowRoot.querySelector('.costream-swap-from-button');
            if(fromElement != null) {
                let fromDataUsername = fromElementButton.dataset.username;

                // copy attributes over
                let fromParentElement = shadowRootElement.shadowRoot.getElementById('costream-section-' + fromDataUsername);
                let toParentElement = shadowRootElement.shadowRoot.getElementById('costream-section-' + toDataUsername);

                let fromClasses = fromParentElement.className;
                let fromStyle = fromParentElement.style.cssText;
                let toClasses = toParentElement.className;
                let toStyle = toParentElement.style.cssText;
                toParentElement.className = fromClasses;
                toParentElement.style = fromStyle;
                fromParentElement.className = toClasses;
                fromParentElement.style = toStyle;

                fromElement.classList.remove('costream-swap-from');
                fromElementButton.classList.remove('costream-swap-from-button');
            } else {
                let parentElement = shadowRootElement.shadowRoot.getElementById('costream-swap-div-' + toDataUsername);
                parentElement.classList.add('costream-swap-from');
                thisElement.classList.add('costream-swap-from-button');
            }
        });
    },
    updated() {
        this.mounted();
    }
}